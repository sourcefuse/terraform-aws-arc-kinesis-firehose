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
    Example = "basic-s3"
  }
}

module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name          = var.s3_bucket_name
  force_destroy = true
  tags          = module.tags.tags
}

module "firehose" {
  source = "../../"

  name        = var.stream_name
  destination = "extended_s3"

  s3_configuration = {
    bucket_arn         = module.s3.bucket_arn
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"
  }

  tags = module.tags.tags
}
