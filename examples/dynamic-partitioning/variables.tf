variable "aws_region" {
  description = "The AWS region where all resources (including Firehose and S3) will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream configured for dynamic partitioning."
  type        = string
  default     = "dynamic-partition-stream"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket where Firehose delivers data with dynamic partitioning enabled."
  type        = string
  default     = "my-firehose-partitioned-bucket"
}