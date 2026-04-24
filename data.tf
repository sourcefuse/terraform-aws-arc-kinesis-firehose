data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# IAM assume role policy for Firehose
data "aws_iam_policy_document" "firehose_assume_role" {
  count = var.create_iam_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

# IAM inline policy document
data "aws_iam_policy_document" "firehose_policy" {
  count = var.create_iam_role ? 1 : 0

  # S3 permissions
  dynamic "statement" {
    for_each = local.needs_s3 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
      ]
      resources = compact([
        var.s3_bucket_arn,
        var.s3_bucket_arn != null ? "${var.s3_bucket_arn}/*" : null,
        var.s3_backup_bucket_arn,
        var.s3_backup_bucket_arn != null ? "${var.s3_backup_bucket_arn}/*" : null,
      ])
    }
  }

  # KMS permissions
  dynamic "statement" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
      resources = [var.kms_key_arn]
    }
  }

  # Lambda transformation permissions
  dynamic "statement" {
    for_each = var.lambda_arn != null ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["lambda:InvokeFunction", "lambda:GetFunctionConfiguration"]
      resources = [var.lambda_arn]
    }
  }

  # CloudWatch Logs permissions
  dynamic "statement" {
    for_each = var.enable_logging ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
      ]
      resources = [
        "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}:log-stream:*"
      ]
    }
  }

  # Glue permissions for format conversion
  dynamic "statement" {
    for_each = var.enable_format_conversion ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["glue:GetTable", "glue:GetTableVersion", "glue:GetTableVersions"]
      resources = ["*"]
    }
  }

  # OpenSearch permissions
  dynamic "statement" {
    for_each = var.destination == "opensearch" ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "es:DescribeDomain",
        "es:DescribeDomains",
        "es:DescribeDomainConfig",
        "es:ESHttpPost",
        "es:ESHttpPut",
        "es:ESHttpGet",
      ]
      resources = compact([
        var.opensearch_domain_arn,
        var.opensearch_domain_arn != null ? "${var.opensearch_domain_arn}/*" : null,
      ])
    }
  }

  # VPC permissions for OpenSearch/Elasticsearch with VPC
  dynamic "statement" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute", "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups", "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface", "ec2:CreateNetworkInterfacePermission",
        "ec2:DeleteNetworkInterface",
      ]
      resources = ["*"]
    }
  }

  # Redshift permissions
  dynamic "statement" {
    for_each = var.destination == "redshift" ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "redshift:GetClusterCredentials",
        "redshift-serverless:GetCredentials",
        "redshift-data:ExecuteStatement",
        "redshift-data:DescribeStatement",
        "redshift-data:GetStatementResult",
      ]
      resources = ["*"]
    }
  }

  # Kinesis source stream permissions
  dynamic "statement" {
    for_each = var.kinesis_source_stream_arn != null ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["kinesis:DescribeStream", "kinesis:GetShardIterator", "kinesis:GetRecords", "kinesis:ListShards"]
      resources = [var.kinesis_source_stream_arn]
    }
  }
}
