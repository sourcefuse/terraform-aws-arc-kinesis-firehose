# Firehose with Lambda Transformation

Demonstrates data transformation using a Lambda function before S3 delivery. 

## What it demonstrates
- Inline Lambda packaging with `archive_file`
- ARC Lambda module (`sourcefuse/arc-lambda-function/aws`) creating the function, IAM role, and CloudWatch log group
- Firehose `lambda:InvokeFunction` permission granted via `lambda_permissions`
- ARC S3 module for the destination bucket

## Architecture

```
Producer → Kinesis Firehose → Lambda (transform) → S3
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose"></a> [firehose](#module\_firehose) | ../../ | n/a |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | sourcefuse/arc-lambda-function/aws | 0.0.2 |
| <a name="module_s3"></a> [s3](#module\_s3) | sourcefuse/arc-s3/aws | 0.0.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.6 |

## Resources

| Name | Type |
|------|------|
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where all resources (Firehose, Lambda, and S3) will be deployed. | `string` | `"us-east-1"` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | The name of the AWS Lambda function responsible for transforming incoming data before it is delivered by Firehose. | `string` | `"firehose-transformer"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the Amazon S3 bucket used as the destination for storing transformed data delivered by Firehose. | `string` | `"my-firehose-lambda-bucket"` | no |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the Kinesis Data Firehose delivery stream that uses a Lambda function for data transformation. | `string` | `"lambda-transform-stream"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name (ID) of the Amazon S3 bucket where the transformed data from Firehose is delivered. |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The Amazon Resource Name (ARN) of the AWS Lambda function used to transform data before delivery by Firehose. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream. Used for integrations, IAM policies, and identifying the stream programmatically. |
| <a name="output_stream_name"></a> [stream\_name](#output\_stream\_name) | The name of the Kinesis Data Firehose delivery stream configured with Lambda data transformation. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->