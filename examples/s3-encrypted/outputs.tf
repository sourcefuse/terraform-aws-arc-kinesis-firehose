output "stream_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream configured with encryption."
  value       = module.firehose.stream_arn
}

output "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS KMS key used to encrypt data in the Firehose delivery stream and/or S3 bucket."
  value       = aws_kms_key.firehose.arn
}

output "bucket_name" {
  description = "The name (ID) of the Amazon S3 bucket where encrypted data from Firehose is delivered."
  value       = module.s3.bucket_id
}