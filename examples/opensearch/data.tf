data "aws_caller_identity" "current" {}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/.build/lambda.zip"
}

data "aws_ssm_parameter" "os_master_password" {
  name            = "/opensearch/${var.os_namespace}/${var.os_environment}/master_user_password"
  with_decryption = true
}

data "aws_opensearch_domain" "firehose_os" {
  domain_name = "firehose-os"
}