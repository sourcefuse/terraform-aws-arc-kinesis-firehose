data "aws_ssm_parameter" "redshift_password" {
  name            = "/arc/poc/analytics/redshift/master-password"
  with_decryption = true
}
