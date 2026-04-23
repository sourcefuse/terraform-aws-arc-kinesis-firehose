# Firehose to Redshift

Delivers data to Amazon Redshift using an S3 staging bucket and the COPY command.

## What it demonstrates
- Redshift destination with S3 staging
- COPY command configuration
- Retry and buffering tuning

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
| <a name="module_s3_staging"></a> [s3\_staging](#module\_s3\_staging) | sourcefuse/arc-s3/aws | 0.0.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.6 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where all resources (Firehose, S3 staging bucket, and Redshift) are deployed. | `string` | `"us-east-1"` | no |
| <a name="input_redshift_columns"></a> [redshift\_columns](#input\_redshift\_columns) | Optional comma-separated list of columns in the Redshift table for data mapping. If null, all columns will be used in default order. | `string` | `null` | no |
| <a name="input_redshift_jdbc_url"></a> [redshift\_jdbc\_url](#input\_redshift\_jdbc\_url) | The JDBC connection URL for the Amazon Redshift cluster (e.g., jdbc:redshift://host:port/database). | `string` | n/a | yes |
| <a name="input_redshift_password"></a> [redshift\_password](#input\_redshift\_password) | The password used for authenticating to the Redshift cluster. Marked as sensitive to prevent exposure in logs. | `string` | n/a | yes |
| <a name="input_redshift_table"></a> [redshift\_table](#input\_redshift\_table) | The target table in Amazon Redshift where Firehose will load the incoming data. | `string` | `"events"` | no |
| <a name="input_redshift_username"></a> [redshift\_username](#input\_redshift\_username) | The username used by Firehose to authenticate and load data into the Redshift cluster. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the Amazon S3 bucket used as a staging area for Firehose before data is copied into Redshift. | `string` | `"my-firehose-redshift-staging"` | no |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the Kinesis Data Firehose delivery stream configured to load data into Amazon Redshift. | `string` | `"redshift-stream"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_staging_bucket"></a> [staging\_bucket](#output\_staging\_bucket) | The name (ID) of the Amazon S3 staging bucket used by Firehose to temporarily store data before loading it into Redshift. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream that loads data into Amazon Redshift. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->