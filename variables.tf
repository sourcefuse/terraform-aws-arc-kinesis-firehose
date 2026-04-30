# ─── General ────────────────────────────────────────────────────────────────

variable "name" {
  description = "Name of the Kinesis Firehose delivery stream."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 64
    error_message = "Stream name must be between 1 and 64 characters."
  }
}

variable "tags" {
  description = "Map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

# ─── Destination ────────────────────────────────────────────────────────────

variable "destination" {
  description = "Destination type. Valid values: extended_s3, redshift, opensearch, http_endpoint."
  type        = string

  validation {
    condition     = contains(["extended_s3", "redshift", "opensearch", "http_endpoint"], var.destination)
    error_message = "destination must be one of: extended_s3, redshift, opensearch, http_endpoint."
  }
}

# ─── IAM ────────────────────────────────────────────────────────────────────

variable "create_iam_role" {
  description = "Whether to create an IAM role for Firehose. Set false to provide an existing role via iam_role_arn."
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "ARN of an existing IAM role. Required when create_iam_role is false."
  type        = string
  default     = null

  validation {
    condition     = var.iam_role_arn == null || can(regex("^arn:", var.iam_role_arn))
    error_message = "iam_role_arn must be a valid ARN."
  }
}

# ─── Encryption ─────────────────────────────────────────────────────────────

variable "kms_key_arn" {
  description = "ARN of a KMS key for server-side encryption. If null, AWS-managed key is used."
  type        = string
  default     = null
}

variable "enable_sse" {
  description = "Enable server-side encryption on the delivery stream."
  type        = bool
  default     = true
}

# ─── Logging ────────────────────────────────────────────────────────────────

variable "logging_config" {
  description = "CloudWatch logging configuration for the delivery stream."
  type = object({
    enable          = optional(bool, true)
    log_group_name  = optional(string, null)
    log_stream_name = optional(string, null)
  })
  default = {}
}

# ─── S3 (extended_s3 destination & staging for other destinations) ───────────

variable "s3_configuration" {
  description = "S3 delivery/staging configuration."
  type = object({
    bucket_arn         = optional(string, null)
    prefix             = optional(string, null)
    error_output_prefix = optional(string, null)
    buffering_size     = optional(number, 5)
    buffering_interval = optional(number, 300)
    compression_format = optional(string, "UNCOMPRESSED")
  })
  default = {}

  validation {
    condition     = var.s3_configuration.buffering_size >= 1 && var.s3_configuration.buffering_size <= 128
    error_message = "s3_configuration.buffering_size must be between 1 and 128."
  }

  validation {
    condition     = var.s3_configuration.buffering_interval >= 0 && var.s3_configuration.buffering_interval <= 900
    error_message = "s3_configuration.buffering_interval must be between 0 and 900."
  }

  validation {
    condition     = contains(["UNCOMPRESSED", "GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY"], var.s3_configuration.compression_format)
    error_message = "s3_configuration.compression_format must be one of: UNCOMPRESSED, GZIP, ZIP, Snappy, HADOOP_SNAPPY."
  }
}

variable "s3_backup_configuration" {
  description = "S3 backup configuration for extended_s3 destination."
  type = object({
    mode       = optional(string, "Disabled")
    bucket_arn = optional(string, null)
  })
  default = {}
}

# ─── Lambda Transformation ───────────────────────────────────────────────────

variable "lambda_arn" {
  description = "ARN of the Lambda function for data transformation. Enables transformation when set."
  type        = string
  default     = null
}

variable "additional_processors" {
  description = "Additional processing configuration blocks (e.g., MetadataExtraction, RecordDeAggregation)."
  type = list(object({
    type = string
    parameters = optional(list(object({
      parameter_name  = string
      parameter_value = string
    })), [])
  }))
  default = []
}

# ─── Format Conversion (Parquet/ORC via Glue) ────────────────────────────────

variable "enable_format_conversion" {
  description = "Enable data format conversion (Parquet/ORC) via AWS Glue."
  type        = bool
  default     = false
}

variable "glue_database_name" {
  description = "Glue database name for schema. Required when enable_format_conversion is true."
  type        = string
  default     = null
}

variable "glue_table_name" {
  description = "Glue table name for schema. Required when enable_format_conversion is true."
  type        = string
  default     = null
}

variable "glue_role_arn" {
  description = "IAM role ARN for Glue access. Defaults to the Firehose role."
  type        = string
  default     = null
}

variable "output_format" {
  description = "Output format for format conversion. Valid values: PARQUET, ORC."
  type        = string
  default     = "PARQUET"

  validation {
    condition     = contains(["PARQUET", "ORC"], var.output_format)
    error_message = "output_format must be PARQUET or ORC."
  }
}

# ─── Dynamic Partitioning ────────────────────────────────────────────────────

variable "enable_dynamic_partitioning" {
  description = "Enable dynamic partitioning for extended_s3 destination."
  type        = bool
  default     = false
}

variable "dynamic_partitioning_retry_duration" {
  description = "Retry duration in seconds for dynamic partitioning (0–7200)."
  type        = number
  default     = 300
}

# ─── Kinesis Source ──────────────────────────────────────────────────────────

variable "kinesis_data_stream" {
  description = "Kinesis Data Stream source configuration."
  type = object({
    stream_arn = string
    role_arn   = optional(string, null)
  })
  default = null
}

# ─── Redshift ────────────────────────────────────────────────────────────────

variable "redshift_configuration" {
  description = "Configuration block for Redshift destination."
  type = object({
    cluster_jdbcurl    = string
    username           = optional(string)
    password           = optional(string)
    data_table_name    = string
    copy_options       = optional(string)
    data_table_columns = optional(string)
    retry_duration     = optional(number, 3600)
    s3_backup_mode     = optional(string, "Disabled")
  })
  default = null
}

# ─── OpenSearch ──────────────────────────────────────────────────────────────

variable "opensearch_domain_arn" {
  description = "ARN of the OpenSearch domain."
  type        = string
  default     = null
}

variable "opensearch_configuration" {
  description = "Configuration block for OpenSearch destination."
  type = object({
    index_name            = string
    index_rotation_period = optional(string, "OneDay")
    buffering_interval    = optional(number, 300)
    buffering_size        = optional(number, 5)
    retry_duration        = optional(number, 300)
    s3_backup_mode        = optional(string, "FailedDocumentsOnly")
    type_name             = optional(string)
    cluster_endpoint      = optional(string)
  })
  default = null
}

# ─── HTTP Endpoint ───────────────────────────────────────────────────────────

variable "http_endpoint_configuration" {
  description = "Configuration block for HTTP endpoint destination."
  type = object({
    url                = string
    name               = optional(string)
    access_key         = optional(string)
    buffering_size     = optional(number, 5)
    buffering_interval = optional(number, 300)
    retry_duration     = optional(number, 300)
    s3_backup_mode     = optional(string, "FailedDataOnly")
    content_encoding   = optional(string, "NONE")
    common_attributes  = optional(list(object({ name = string, value = string })), [])
  })
  default = null
}

# ─── VPC ─────────────────────────────────────────────────────────────────────

variable "vpc_config" {
  description = "VPC configuration for OpenSearch destination."
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
    role_arn           = optional(string)
  })
  default = null
}
