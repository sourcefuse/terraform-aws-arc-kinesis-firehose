variable "aws_region" {
  description = "The AWS region where all resources (Firehose, S3 staging bucket, and Redshift) are deployed."
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream configured to load data into Amazon Redshift."
  type        = string
  default     = "redshift-stream"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket used as a staging area for Firehose before data is copied into Redshift."
  type        = string
  default     = "my-firehose-redshift-staging"
}

variable "redshift_jdbc_url" {
  description = "The JDBC connection URL for the Amazon Redshift cluster (e.g., jdbc:redshift://host:port/database)."
  type        = string
  default     = "jdbc:redshift://arc-poc-analytics.x4xxxxxx2kux.us-east-1.redshift.amazonaws.com:5439/analytics"
}

variable "redshift_username" {
  description = "The username used by Firehose to authenticate and load data into the Redshift cluster."
  type        = string
  default     = "admin"
}

variable "redshift_table" {
  description = "The target table in Amazon Redshift where Firehose will load the incoming data."
  type        = string
  default     = "firehose_test_table"
}
