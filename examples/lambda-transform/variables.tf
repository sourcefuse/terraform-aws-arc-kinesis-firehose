variable "aws_region" {
  description = "The AWS region where all resources (Firehose, Lambda, and S3) will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream that uses a Lambda function for data transformation."
  type        = string
  default     = "lambda-transform-stream"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket used as the destination for storing transformed data delivered by Firehose."
  type        = string
  default     = "my-firehose-lambda-bucket"
}

variable "function_name" {
  description = "The name of the AWS Lambda function responsible for transforming incoming data before it is delivered by Firehose."
  type        = string
  default     = "firehose-transformer"
}