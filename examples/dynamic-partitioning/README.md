# Firehose with Dynamic Partitioning

Partitions S3 data by extracted JSON fields -  using JQ metadata extraction.

## What it demonstrates
- Dynamic partitioning with JQ processor
- S3 prefix patterns using `partitionKeyFromQuery`
- `AppendDelimiterToRecord` processor for newline-delimited output

> Note: Dynamic partitioning cannot be disabled once enabled on a stream. Changing this setting will recreate the resource.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose"></a> [firehose](#module\_firehose) | ../../ | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | sourcefuse/arc-s3/aws | 0.0.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.6 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where all resources (including Firehose and S3) will be deployed. | `string` | `"us-east-1"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the Amazon S3 bucket where Firehose delivers data with dynamic partitioning enabled. | `string` | `"my-firehose-partitioned-bucket"` | no |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the Kinesis Data Firehose delivery stream configured for dynamic partitioning. | `string` | `"dynamic-partition-stream"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream. Used for IAM policies, integrations, and referencing the stream programmatically. |
| <a name="output_stream_name"></a> [stream\_name](#output\_stream\_name) | The name of the Kinesis Data Firehose delivery stream. This is used to identify and interact with the stream in AWS services. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->