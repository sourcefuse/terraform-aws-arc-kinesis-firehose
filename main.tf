# ─── IAM Role ────────────────────────────────────────────────────────────────

resource "aws_iam_role" "firehose" {
  count = var.create_iam_role ? 1 : 0

  name               = "${local.stream_name}-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role[0].json

  tags = local.tags
}

resource "aws_iam_role_policy" "firehose" {
  count = var.create_iam_role ? 1 : 0

  name   = "${local.stream_name}-firehose-policy"
  role   = aws_iam_role.firehose[0].id
  policy = data.aws_iam_policy_document.firehose_policy[0].json
}

# ─── CloudWatch Log Group & Stream ───────────────────────────────────────────

resource "aws_cloudwatch_log_group" "firehose" {
  count = local.enable_logging ? 1 : 0

  name              = local.log_group_name
  retention_in_days = 14

  tags = local.tags
}

resource "aws_cloudwatch_log_stream" "firehose" {
  count = local.enable_logging ? 1 : 0

  name           = local.log_stream_name
  log_group_name = aws_cloudwatch_log_group.firehose[0].name
}

# ─── Kinesis Firehose Delivery Stream ────────────────────────────────────────

resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = local.stream_name
  destination = var.destination

  tags = local.tags

  # ── Kinesis source ──
  dynamic "kinesis_source_configuration" {
    for_each = var.kinesis_data_stream != null ? [1] : []
    content {
      kinesis_stream_arn = var.kinesis_data_stream.stream_arn
      role_arn           = coalesce(var.kinesis_data_stream.role_arn, local.iam_role_arn)
    }
  }

  # ── Server-side encryption ──
  dynamic "server_side_encryption" {
    for_each = var.enable_sse && var.kinesis_data_stream == null ? [1] : []
    content {
      enabled  = true
      key_type = var.kms_key_arn != null ? "CUSTOMER_MANAGED_CMK" : "AWS_OWNED_CMK"
      key_arn  = var.kms_key_arn
    }
  }

  # ════════════════════════════════════════════════════════════════════════════
  # Extended S3
  # ════════════════════════════════════════════════════════════════════════════
  dynamic "extended_s3_configuration" {
    for_each = var.destination == "extended_s3" ? [1] : []
    content {
      role_arn            = local.iam_role_arn
      bucket_arn          = var.s3_configuration.bucket_arn
      prefix              = var.s3_configuration.prefix
      error_output_prefix = var.s3_configuration.error_output_prefix
      buffering_size      = var.enable_format_conversion ? max(var.s3_configuration.buffering_size, 64) : var.s3_configuration.buffering_size
      buffering_interval  = var.s3_configuration.buffering_interval
      compression_format  = var.enable_format_conversion ? "UNCOMPRESSED" : var.s3_configuration.compression_format
      kms_key_arn         = var.kms_key_arn
      s3_backup_mode      = var.s3_backup_configuration.mode

      # Dynamic partitioning
      dynamic "dynamic_partitioning_configuration" {
        for_each = var.enable_dynamic_partitioning ? [1] : []
        content {
          enabled        = true
          retry_duration = var.dynamic_partitioning_retry_duration
        }
      }

      # Processing configuration
      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = true
          dynamic "processors" {
            for_each = local.all_processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      # Data format conversion
      dynamic "data_format_conversion_configuration" {
        for_each = var.enable_format_conversion ? [1] : []
        content {
          enabled = true

          input_format_configuration {
            deserializer {
              open_x_json_ser_de {}
            }
          }

          output_format_configuration {
            serializer {
              dynamic "parquet_ser_de" {
                for_each = var.output_format == "PARQUET" ? [1] : []
                content {}
              }
              dynamic "orc_ser_de" {
                for_each = var.output_format == "ORC" ? [1] : []
                content {}
              }
            }
          }

          schema_configuration {
            database_name = var.glue_database_name
            table_name    = var.glue_table_name
            role_arn      = coalesce(var.glue_role_arn, local.iam_role_arn)
          }
        }
      }

      # S3 backup
      dynamic "s3_backup_configuration" {
        for_each = var.s3_backup_configuration.mode == "Enabled" && var.s3_backup_configuration.bucket_arn != null ? [1] : []
        content {
          role_arn           = local.iam_role_arn
          bucket_arn         = var.s3_backup_configuration.bucket_arn
          buffering_size     = var.s3_configuration.buffering_size
          buffering_interval = var.s3_configuration.buffering_interval
          compression_format = var.s3_configuration.compression_format
          kms_key_arn        = var.kms_key_arn
        }
      }

      # CloudWatch logging
      dynamic "cloudwatch_logging_options" {
        for_each = local.enable_logging ? [1] : []
        content {
          enabled         = true
          log_group_name  = local.log_group_name
          log_stream_name = local.log_stream_name
        }
      }
    }
  }

  # ════════════════════════════════════════════════════════════════════════════
  # Redshift
  # ════════════════════════════════════════════════════════════════════════════
  dynamic "redshift_configuration" {
    for_each = var.destination == "redshift" && var.redshift_configuration != null ? [var.redshift_configuration] : []
    content {
      role_arn           = local.iam_role_arn
      cluster_jdbcurl    = redshift_configuration.value.cluster_jdbcurl
      username           = redshift_configuration.value.username
      password           = redshift_configuration.value.password
      data_table_name    = redshift_configuration.value.data_table_name
      copy_options       = redshift_configuration.value.copy_options
      data_table_columns = redshift_configuration.value.data_table_columns
      retry_duration     = redshift_configuration.value.retry_duration
      s3_backup_mode     = redshift_configuration.value.s3_backup_mode

      s3_configuration {
        role_arn           = local.iam_role_arn
        bucket_arn         = var.s3_configuration.bucket_arn
        buffering_size     = var.s3_configuration.buffering_size
        buffering_interval = var.s3_configuration.buffering_interval
        compression_format = var.s3_configuration.compression_format
        kms_key_arn        = var.kms_key_arn
      }

      dynamic "s3_backup_configuration" {
        for_each = redshift_configuration.value.s3_backup_mode == "Enabled" && var.s3_backup_configuration.bucket_arn != null ? [1] : []
        content {
          role_arn           = local.iam_role_arn
          bucket_arn         = var.s3_backup_configuration.bucket_arn
          buffering_size     = var.s3_configuration.buffering_size
          buffering_interval = var.s3_configuration.buffering_interval
          compression_format = var.s3_configuration.compression_format
        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = true
          dynamic "processors" {
            for_each = local.all_processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = local.enable_logging ? [1] : []
        content {
          enabled         = true
          log_group_name  = local.log_group_name
          log_stream_name = local.log_stream_name
        }
      }
    }
  }

  # ════════════════════════════════════════════════════════════════════════════
  # OpenSearch
  # ════════════════════════════════════════════════════════════════════════════
  dynamic "opensearch_configuration" {
    for_each = var.destination == "opensearch" && var.opensearch_configuration != null ? [var.opensearch_configuration] : []
    content {
      role_arn              = local.iam_role_arn
      domain_arn            = opensearch_configuration.value.cluster_endpoint == null ? var.opensearch_domain_arn : null
      cluster_endpoint      = opensearch_configuration.value.cluster_endpoint
      index_name            = opensearch_configuration.value.index_name
      index_rotation_period = opensearch_configuration.value.index_rotation_period
      buffering_interval    = opensearch_configuration.value.buffering_interval
      buffering_size        = opensearch_configuration.value.buffering_size
      retry_duration        = opensearch_configuration.value.retry_duration
      s3_backup_mode        = opensearch_configuration.value.s3_backup_mode
      type_name             = opensearch_configuration.value.type_name

      s3_configuration {
        role_arn           = local.iam_role_arn
        bucket_arn         = var.s3_configuration.bucket_arn
        buffering_size     = var.s3_configuration.buffering_size
        buffering_interval = var.s3_configuration.buffering_interval
        compression_format = var.s3_configuration.compression_format
        kms_key_arn        = var.kms_key_arn
      }

      dynamic "vpc_config" {
        for_each = var.vpc_config != null ? [var.vpc_config] : []
        content {
          subnet_ids         = vpc_config.value.subnet_ids
          security_group_ids = vpc_config.value.security_group_ids
          role_arn           = coalesce(vpc_config.value.role_arn, local.iam_role_arn)
        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = true
          dynamic "processors" {
            for_each = local.all_processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = local.enable_logging ? [1] : []
        content {
          enabled         = true
          log_group_name  = local.log_group_name
          log_stream_name = local.log_stream_name
        }
      }
    }
  }

  # ════════════════════════════════════════════════════════════════════════════
  # HTTP Endpoint
  # ════════════════════════════════════════════════════════════════════════════
  dynamic "http_endpoint_configuration" {
    for_each = var.destination == "http_endpoint" && var.http_endpoint_configuration != null ? [var.http_endpoint_configuration] : []
    content {
      url                = http_endpoint_configuration.value.url
      name               = http_endpoint_configuration.value.name
      access_key         = http_endpoint_configuration.value.access_key
      role_arn           = local.iam_role_arn
      buffering_size     = http_endpoint_configuration.value.buffering_size
      buffering_interval = http_endpoint_configuration.value.buffering_interval
      retry_duration     = http_endpoint_configuration.value.retry_duration
      s3_backup_mode     = http_endpoint_configuration.value.s3_backup_mode

      s3_configuration {
        role_arn           = local.iam_role_arn
        bucket_arn         = var.s3_configuration.bucket_arn
        buffering_size     = var.s3_configuration.buffering_size
        buffering_interval = var.s3_configuration.buffering_interval
        compression_format = var.s3_configuration.compression_format
        kms_key_arn        = var.kms_key_arn
      }

      request_configuration {
        content_encoding = http_endpoint_configuration.value.content_encoding

        dynamic "common_attributes" {
          for_each = http_endpoint_configuration.value.common_attributes
          content {
            name  = common_attributes.value.name
            value = common_attributes.value.value
          }
        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = true
          dynamic "processors" {
            for_each = local.all_processors
            content {
              type = processors.value.type
              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = local.enable_logging ? [1] : []
        content {
          enabled         = true
          log_group_name  = local.log_group_name
          log_stream_name = local.log_stream_name
        }
      }
    }
  }

  depends_on = [
    aws_cloudwatch_log_stream.firehose,
    aws_iam_role_policy.firehose,
  ]
}
