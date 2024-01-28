terraform {
  backend "s3" {
    bucket = "bsc.sandbox.terraform.state"
    key    = "aws_snowflake_feedback"
    region = "us-east-2"
  }
}