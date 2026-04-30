variable "aws_region" {
  description = "The AWS region where all resources (Firehose, S3, KMS, and optional Glue) will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream configured with server-side encryption."
  type        = string
  default     = "s3-encrypted-stream"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket used as the destination for storing encrypted Firehose data."
  type        = string
  default     = "my-firehose-encrypted-bucket"
}

variable "enable_parquet" {
  description = "Boolean flag to enable data format conversion to Parquet using AWS Glue schema. When true, Firehose converts incoming data before storing it in S3."
  type        = bool
  default     = false
}

variable "glue_database_name" {
  description = "The name of the AWS Glue Data Catalog database used for schema reference during Firehose data format conversion (required if Parquet conversion is enabled)."
  type        = string
  default     = null
}

variable "glue_table_name" {
  description = "The name of the AWS Glue table that defines the schema for Firehose data format conversion to Parquet (required if Parquet conversion is enabled)."
  type        = string
  default     = null
}