variable "aws_region" {
  description = "The AWS region where all resources (Firehose, Lambda, S3, and OpenSearch) are deployed."
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream responsible for sending data to OpenSearch."
  type        = string
  default     = "opensearch-stream"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket used as a backup or intermediate storage for Firehose delivery failures or buffering."
  type        = string
  default     = "my-firehose-opensearch-bucket"
}

variable "function_name" {
  description = "The name of the AWS Lambda function used to preprocess or transform records before indexing into OpenSearch."
  type        = string
  default     = "firehose-opensearch-transformer"
}

variable "os_namespace" {
  description = "The namespace identifier used by the OpenSearch infrastructure. Must match the value used to construct the SSM parameter path for domain lookup."
  type        = string
  default     = "arc"
}

variable "os_environment" {
  description = "The environment identifier (e.g., dev, stg, prod) used by the OpenSearch infrastructure. Must match the SSM parameter path for resolving domain details."
  type        = string
  default     = "dev"
}

variable "opensearch_index_name" {
  description = "The name of the OpenSearch index where Firehose will store incoming data."
  type        = string
  default     = "firehose-index"
}