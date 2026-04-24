locals {
  name_prefix = var.name_prefix != null ? "${var.name_prefix}-" : ""
  stream_name = "${local.name_prefix}${var.name}"

  iam_role_arn = var.create_iam_role ? aws_iam_role.firehose[0].arn : var.iam_role_arn

  log_group_name  = var.log_group_name != null ? var.log_group_name : "/aws/kinesisfirehose/${local.stream_name}"
  log_stream_name = var.log_stream_name != null ? var.log_stream_name : "DestinationDelivery"

  needs_s3 = contains(["extended_s3", "redshift", "opensearch", "http_endpoint"], var.destination)

  tags = merge(var.tags, {
    Name      = local.stream_name
    ManagedBy = "terraform"
  })

  # Shared processing configuration
  enable_processing = var.lambda_arn != null || length(var.additional_processors) > 0

  lambda_processor = var.lambda_arn != null ? [{
    type = "Lambda"
    parameters = [{
      parameter_name  = "LambdaArn"
      parameter_value = var.lambda_arn
    }]
  }] : []

  all_processors = concat(local.lambda_processor, var.additional_processors)
}
