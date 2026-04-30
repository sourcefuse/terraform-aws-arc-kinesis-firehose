output "stream_arn" {
  description = "The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream used to ingest and deliver data to OpenSearch."
  value       = module.firehose.stream_arn
}

output "stream_name" {
  description = "The name of the Kinesis Data Firehose delivery stream configured to send data to OpenSearch."
  value       = module.firehose.stream_name
}

output "lambda_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS Lambda function used to transform data before it is indexed in OpenSearch."
  value       = module.lambda.arn
}

output "opensearch_domain_arn" {
  description = "The Amazon Resource Name (ARN) of the OpenSearch domain where Firehose delivers data."
  value       = data.aws_opensearch_domain.firehose_os.arn
}

output "opensearch_domain_endpoint" {
  description = "The endpoint URL of the OpenSearch domain used by Firehose to index incoming data."
  value       = data.aws_opensearch_domain.firehose_os.endpoint
}