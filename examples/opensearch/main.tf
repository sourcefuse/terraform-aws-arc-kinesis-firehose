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
    opensearch = {
      source  = "opensearch-project/opensearch",
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "opensearch" {
  url               = "https://${data.aws_opensearch_domain.firehose_os.endpoint}"
  username          = "admin"
  password          = data.aws_ssm_parameter.os_master_password.value
  healthcheck       = false
  sign_aws_requests = false
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.6"

  environment = "production"
  project     = "terraform-aws-arc-kinesis-firehose"

  extra_tags = {
    Example = "opensearch"
  }
}

# ── S3 bucket for Firehose backup / failed docs ───────────────────────────────

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
  description   = "Firehose record transformation function for OpenSearch"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  memory_size   = 128
  timeout       = 60

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  create_log_group      = true
  log_retention_in_days = 7

  lambda_permissions = {
    firehose = {
      action         = "lambda:InvokeFunction"
      principal      = "firehose.amazonaws.com"
      source_account = data.aws_caller_identity.current.account_id
    }
  }

  tags = module.tags.tags
}

# ── Firehose → OpenSearch delivery stream ────────────────────────────────────

module "firehose" {
  source = "../../"

  name        = var.stream_name
  destination = "opensearch"

  s3_bucket_arn         = module.s3.bucket_arn
  s3_compression_format = "GZIP"

  opensearch_domain_arn = data.aws_opensearch_domain.firehose_os.arn

  opensearch_configuration = {
    index_name            = var.opensearch_index_name
    index_rotation_period = "OneDay"
    buffering_interval    = 60
    buffering_size        = 1
    retry_duration        = 300
    s3_backup_mode        = "FailedDocumentsOnly"
  }

  lambda_arn     = module.lambda.arn
  enable_logging = true
  tags           = module.tags.tags
}

# ── Map Firehose IAM role to OpenSearch firehose_writer role ───────────────────────

resource "opensearch_role" "firehose_role" {
  role_name = "firehose_writer"

  cluster_permissions = ["*"]

  index_permissions {
    index_patterns  = ["${var.opensearch_index_name}*"]
    allowed_actions = ["write", "create_index"]
  }
}

resource "opensearch_roles_mapping" "firehose" {
  role_name     = opensearch_role.firehose_role.role_name
  backend_roles = [module.firehose.iam_role_arn]
  depends_on    = [module.firehose, opensearch_role.firehose_role]
}



