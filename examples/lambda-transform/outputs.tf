output "stream_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream. Used for integrations, IAM policies, and identifying the stream programmatically."
  value       = module.firehose.stream_arn
}

output "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream configured with Lambda data transformation."
  value       = module.firehose.stream_name
}

output "lambda_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS Lambda function used to transform data before delivery by Firehose."
  value       = module.lambda.arn
}

output "bucket_name" {
  description = "The name (ID) of the Amazon S3 bucket where the transformed data from Firehose is delivered."
  value       = module.s3.bucket_id
}