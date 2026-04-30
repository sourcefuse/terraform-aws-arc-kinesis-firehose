variable "aws_region" {
  description = "The AWS region where all resources (including Kinesis Data Firehose and S3) will be created."
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream. This name must be unique within the AWS account and region."
  type        = string
  default     = "basic-s3-stream"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket used as the destination for Kinesis Data Firehose data delivery."
  type        = string
  default     = "my-firehose-basic-s3-bucket"
}