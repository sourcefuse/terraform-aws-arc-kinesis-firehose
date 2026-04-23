# Firehose to S3 with Encryption

Demonstrates KMS-encrypted S3 delivery with optional Parquet format conversion via Glue.

## What it demonstrates
- Customer-managed KMS key for S3 and Firehose encryption
- Server-side encryption on the delivery stream
- Optional Parquet format conversion (set `enable_parquet = true` with Glue config)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose"></a> [firehose](#module\_firehose) | ../../ | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | sourcefuse/arc-s3/aws | 0.0.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.6 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where all resources (Firehose, S3, KMS, and optional Glue) will be deployed. | `string` | `"us-east-1"` | no |
| <a name="input_enable_parquet"></a> [enable\_parquet](#input\_enable\_parquet) | Boolean flag to enable data format conversion to Parquet using AWS Glue schema. When true, Firehose converts incoming data before storing it in S3. | `bool` | `false` | no |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | The name of the AWS Glue Data Catalog database used for schema reference during Firehose data format conversion (required if Parquet conversion is enabled). | `string` | `null` | no |
| <a name="input_glue_table_name"></a> [glue\_table\_name](#input\_glue\_table\_name) | The name of the AWS Glue table that defines the schema for Firehose data format conversion to Parquet (required if Parquet conversion is enabled). | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the Amazon S3 bucket used as the destination for storing encrypted Firehose data. | `string` | `"my-firehose-encrypted-bucket"` | no |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the Kinesis Data Firehose delivery stream configured with server-side encryption. | `string` | `"s3-encrypted-stream"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name (ID) of the Amazon S3 bucket where encrypted data from Firehose is delivered. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The Amazon Resource Name (ARN) of the AWS KMS key used to encrypt data in the Firehose delivery stream and/or S3 bucket. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream configured with encryption. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->