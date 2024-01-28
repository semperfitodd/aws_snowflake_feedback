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

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}