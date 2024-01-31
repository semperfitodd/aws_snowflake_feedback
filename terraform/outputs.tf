output "snowflake_role_arn" {
  value = aws_iam_role.snowflake_user.arn
}

output "snowflake_s3_bucket" {
  value = module.snowflake_s3_bucket.s3_bucket_id
}
