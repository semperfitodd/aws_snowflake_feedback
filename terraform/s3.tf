data "aws_iam_policy_document" "site" {
  statement {
    effect = "Allow"
    principals {
      identifiers = module.cdn.cloudfront_origin_access_identity_iam_arns
      type        = "AWS"
    }
    actions   = ["s3:GetObject"]
    resources = ["${module.site_s3_bucket.s3_bucket_arn}/*"]
  }
}

locals {
  environment = replace(var.environment, "_", "-")

  site_directory = "${path.module}/static-site/build"

  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/ico"
    "jpg"  = "image/jpeg"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/octet-stream"
    "png"  = "image/png"
    "txt"  = "text/plain"
  }
}

module "all_notifications" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  count  = var.snowflake_sqs_arn != null ? 1 : 0

  bucket = module.snowflake_s3_bucket.s3_bucket_id

  create_sqs_policy = false

  sqs_notifications = {
    sqs1 = {
      events    = ["s3:ObjectCreated:Put"]
      queue_arn = var.snowflake_sqs_arn
    }
  }
}

module "ses_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.environment}-ses"

  attach_public_policy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

module "site_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.site_domain

  attach_public_policy = true
  attach_policy        = true
  policy               = data.aws_iam_policy_document.site.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

module "snowflake_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.environment}-snowflake"

  attach_public_policy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id                                     = "email"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      expiration = {
        days = 32
      }
    }
  ]

  tags = var.tags
}

resource "aws_s3_object" "website-object" {
  for_each = fileset(local.site_directory, "**/*")

  bucket       = module.site_s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${local.site_directory}/${each.value}"
  etag         = filemd5("${local.site_directory}/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}