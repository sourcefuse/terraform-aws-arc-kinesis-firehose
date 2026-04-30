output "stream_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream that loads data into Amazon Redshift."
  value       = module.firehose.stream_arn
}

output "staging_bucket" {
  description = "The name (ID) of the Amazon S3 staging bucket used by Firehose to temporarily store data before loading it into Redshift."
  value       = module.s3_staging.bucket_id
}