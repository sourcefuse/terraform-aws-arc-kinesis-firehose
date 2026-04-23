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
    Example = "dynamic-partitioning"
  }
}

module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name          = var.s3_bucket_name
  force_destroy = false
  tags          = module.tags.tags
}

module "firehose" {
  source = "../../"

  name        = var.stream_name
  destination = "extended_s3"

  s3_bucket_arn         = module.s3.bucket_arn
  s3_buffering_size     = 64
  s3_buffering_interval = 60

  s3_prefix              = "data/sector=!{partitionKeyFromQuery:sector}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  s3_error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

  enable_dynamic_partitioning         = true
  dynamic_partitioning_retry_duration = 300

  additional_processors = [
    {
      type = "MetadataExtraction"
      parameters = [
        { parameter_name = "JsonParsingEngine", parameter_value = "JQ-1.6" },
        { parameter_name = "MetadataExtractionQuery", parameter_value = "{sector:.SECTOR}" }
      ]
    },
    {
      type       = "AppendDelimiterToRecord"
      parameters = []
    }
  ]

  enable_logging = true
  tags           = module.tags.tags
}
