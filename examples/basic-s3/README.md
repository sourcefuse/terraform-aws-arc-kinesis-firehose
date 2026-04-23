# Basic Firehose to S3

Demonstrates the simplest Firehose delivery stream delivering data to S3 with GZIP compression.

## What it demonstrates
- Creating a Firehose delivery stream with `extended_s3` destination
- Auto-created IAM role with least-privilege S3 permissions
- CloudWatch logging enabled by default
- GZIP compression

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where all resources (including Kinesis Data Firehose and S3) will be created. | `string` | `"us-east-1"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the Amazon S3 bucket used as the destination for Kinesis Data Firehose data delivery. | `string` | `"my-firehose-basic-s3-bucket"` | no |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the Kinesis Data Firehose delivery stream. This name must be unique within the AWS account and region. | `string` | `"basic-s3-stream"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name (ID) of the Amazon S3 bucket where the Kinesis Data Firehose delivers data. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream. This uniquely identifies the Firehose stream and is used for permissions and integrations. |
| <a name="output_stream_name"></a> [stream\_name](#output\_stream\_name) | The name of the Kinesis Data Firehose delivery stream. This is used to reference the stream in AWS services and configurations. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->