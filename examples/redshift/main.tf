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
    Example = "redshift"
  }
}

module "s3_staging" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name          = var.s3_bucket_name
  force_destroy = true
  tags          = module.tags.tags
}

module "firehose" {
  source = "../../"

  name        = var.stream_name
  destination = "redshift"

  s3_bucket_arn         = module.s3_staging.bucket_arn
  s3_buffering_size     = 10
  s3_buffering_interval = 400
  s3_compression_format = "GZIP"

  redshift_configuration = {
    cluster_jdbcurl = var.redshift_jdbc_url
    username        = var.redshift_username
    password        = data.aws_ssm_parameter.redshift_password.value
    data_table_name = var.redshift_table
    copy_options    = "json 'auto ignorecase' gzip"
  }

  enable_logging = true
  tags           = module.tags.tags
}
