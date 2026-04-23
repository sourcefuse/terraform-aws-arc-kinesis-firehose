# Firehose to OpenSearch

Streams data into an Amazon OpenSearch Service domain with S3 backup for failed documents.

## What it demonstrates
- OpenSearch destination with index rotation
- S3 backup for failed documents
- Optional Lambda transformation

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_opensearch"></a> [opensearch](#provider\_opensearch) | >= 2.0 |

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
| [opensearch_role.firehose_role](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/role) | resource |
| [opensearch_roles_mapping.firehose](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/roles_mapping) | resource |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_opensearch_domain.firehose_os](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/opensearch_domain) | data source |
| [aws_ssm_parameter.os_master_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where all resources (Firehose, Lambda, S3, and OpenSearch) are deployed. | `string` | `"us-east-1"` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | The name of the AWS Lambda function used to preprocess or transform records before indexing into OpenSearch. | `string` | `"firehose-opensearch-transformer"` | no |
| <a name="input_opensearch_index_name"></a> [opensearch\_index\_name](#input\_opensearch\_index\_name) | The name of the OpenSearch index where Firehose will store incoming data. | `string` | `"firehose-index"` | no |
| <a name="input_os_environment"></a> [os\_environment](#input\_os\_environment) | The environment identifier (e.g., dev, stg, prod) used by the OpenSearch infrastructure. Must match the SSM parameter path for resolving domain details. | `string` | `"dev"` | no |
| <a name="input_os_namespace"></a> [os\_namespace](#input\_os\_namespace) | The namespace identifier used by the OpenSearch infrastructure. Must match the value used to construct the SSM parameter path for domain lookup. | `string` | `"arc"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the Amazon S3 bucket used as a backup or intermediate storage for Firehose delivery failures or buffering. | `string` | `"my-firehose-opensearch-bucket"` | no |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the Kinesis Data Firehose delivery stream responsible for sending data to OpenSearch. | `string` | `"opensearch-stream"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The Amazon Resource Name (ARN) of the AWS Lambda function used to transform data before it is indexed in OpenSearch. |
| <a name="output_opensearch_domain_arn"></a> [opensearch\_domain\_arn](#output\_opensearch\_domain\_arn) | The Amazon Resource Name (ARN) of the OpenSearch domain where Firehose delivers data. |
| <a name="output_opensearch_domain_endpoint"></a> [opensearch\_domain\_endpoint](#output\_opensearch\_domain\_endpoint) | The endpoint URL of the OpenSearch domain used by Firehose to index incoming data. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The Amazon Resource Name (ARN) of the Kinesis Data Firehose delivery stream used to ingest and deliver data to OpenSearch. |
| <a name="output_stream_name"></a> [stream\_name](#output\_stream\_name) | The name of the Kinesis Data Firehose delivery stream configured to send data to OpenSearch. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->