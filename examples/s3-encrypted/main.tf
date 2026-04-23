terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">= 5.0.0"
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
    Example = "s3-encrypted"
  }
}

resource "aws_kms_key" "firehose" {
  description             = "KMS key for Firehose S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = module.tags.tags
}

module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name          = var.s3_bucket_name
  force_destroy = true
  tags          = module.tags.tags

  server_side_encryption_config_data = {
    sse_algorithm     = "aws:kms"
    kms_master_key_id = aws_kms_key.firehose.arn
  }
}

module "firehose" {
  source = "../../"

  name        = var.stream_name
  destination = "extended_s3"

  s3_bucket_arn         = module.s3.bucket_arn
  s3_compression_format = "GZIP"
  kms_key_arn           = aws_kms_key.firehose.arn
  enable_sse            = true

  enable_format_conversion = var.enable_parquet
  glue_database_name       = var.enable_parquet ? var.glue_database_name : null
  glue_table_name          = var.enable_parquet ? var.glue_table_name : null
  output_format            = "PARQUET"

  enable_logging = true
  tags           = module.tags.tags
}
