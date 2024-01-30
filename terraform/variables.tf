variable "domain" {
  description = "Domain"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment all resources will be built"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region where resources will be deployed"
  type        = string
  default     = null
}

variable "site_domain" {
  description = "domain for the web application"
  type        = string
  default     = null
}

variable "snowflake_aws_user_arn" {
  description = "AWS account number where Snowflake is hosted"
  type = string
  default = "arn:aws:iam::099720109477:root" # Default value of canonical for first TF apply
}

variable "snowflake_external_id" {
  description = "External ID for AWS Trusted ID"
  type = string
  default = "0000" # Default value to allow first TF apply
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}
