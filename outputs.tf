output "stream_arn" {
  description = "ARN of the Kinesis Firehose delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.this.arn
}

output "stream_name" {
  description = "Name of the Kinesis Firehose delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.this.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by Firehose."
  value       = local.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role created for Firehose (null if externally provided)."
  value       = var.create_iam_role ? aws_iam_role.firehose[0].name : null
}

output "log_group_name" {
  description = "CloudWatch log group name."
  value       = var.enable_logging ? aws_cloudwatch_log_group.firehose[0].name : null
}

output "log_stream_name" {
  description = "CloudWatch log stream name."
  value       = var.enable_logging ? aws_cloudwatch_log_stream.firehose[0].name : null
}
