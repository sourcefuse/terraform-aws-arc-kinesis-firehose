terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">= 5.0.0"
    }
    archive = {
      source  = "hashicorp/archive",
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.6"

  environment = "production"
  project     = "terraform-aws-arc-kinesis-firehose"

  extra_tags = {
    Example = "lambda-transform"
  }
}

data "aws_caller_identity" "current" {}

# ── Package the Lambda source into a zip ─────────────────────────────────────

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/.build/lambda.zip"
}

# ── S3 bucket for Firehose delivery ──────────────────────────────────────────

module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name          = var.s3_bucket_name
  force_destroy = true
  tags          = module.tags.tags
}

# ── Lambda transformation function ───────────────────────────────────────────

module "lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.2"

  function_name = var.function_name
  description   = "Firehose record transformation function"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  memory_size   = 128
  timeout       = 60 # Firehose allows up to 5 min; 60 s is a safe default

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  create_log_group      = true
  log_retention_in_days = 7

  # Allow Firehose to invoke this Lambda.
  # source_arn is scoped to the account to avoid a circular dependency
  # (stream ARN depends on Lambda ARN, Lambda permission depends on stream ARN).
  lambda_permissions = {
    firehose = {
      action         = "lambda:InvokeFunction"
      principal      = "firehose.amazonaws.com"
      source_account = data.aws_caller_identity.current.account_id
    }
  }

  tags = module.tags.tags
}

# ── Firehose delivery stream ──────────────────────────────────────────────────

module "firehose" {
  source = "../../"

  name        = var.stream_name
  destination = "extended_s3"

  s3_configuration = {
    bucket_arn         = module.s3.bucket_arn
    compression_format = "GZIP"
  }

  lambda_arn = module.lambda.arn

  tags = module.tags.tags
}
