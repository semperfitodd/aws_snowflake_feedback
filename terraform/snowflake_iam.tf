data "aws_iam_policy_document" "snowflake_user" {
  statement {
    effect = "Allow"
    resources = [
      "${module.ses_s3_bucket.s3_bucket_arn}/*",
      "${module.snowflake_s3_bucket.s3_bucket_arn}/*",
    ]
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      module.ses_s3_bucket.s3_bucket_arn,
      module.snowflake_s3_bucket.s3_bucket_arn,
    ]
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
  }
}

resource "aws_iam_policy" "snowflake_user" {
  name        = "${var.environment}_snowflake_user"
  description = "${var.environment} snowflake user permission policy"

  policy = data.aws_iam_policy_document.snowflake_user.json
}

resource "aws_iam_role" "snowflake_user" {
  name        = "${var.environment}_snowflake_user"
  description = "${var.environment} snowflake user permission role"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Condition = {
            StringEquals = {
              "sts:ExternalId" = var.snowflake_external_id
            }
          }
          Principal = {
            AWS = var.snowflake_aws_user_arn
          }
          Action = "sts:AssumeRole"
          Effect = "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "snowflake_user" {
  policy_arn = aws_iam_policy.snowflake_user.arn
  role       = aws_iam_role.snowflake_user.name
}
