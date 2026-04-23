output "stream_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream. This uniquely identifies the Firehose stream and is used for permissions and integrations."
  value       = module.firehose.stream_arn
}

output "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream. This is used to reference the stream in AWS services and configurations."
  value       = module.firehose.stream_name
}

output "bucket_name" {
  description = "The name (ID) of the Amazon S3 bucket where the Kinesis Data Firehose delivers data."
  value       = module.s3.bucket_id
}