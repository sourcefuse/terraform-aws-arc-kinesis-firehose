output "stream_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream. Used for IAM policies, integrations, and referencing the stream programmatically."
  value       = module.firehose.stream_arn
}

output "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream. This is used to identify and interact with the stream in AWS services."
  value       = module.firehose.stream_name
}
