module "lambda_function_snowflake" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.environment}_snowflake"
  description   = "${var.environment} function to put emails into snowflake"
  handler       = "app.lambda_handler"
  publish       = true
  runtime       = "python3.11"
  timeout       = 300

  source_path = [
    {
      path             = "${path.module}/lambda_snowflake"
      pip_requirements = false
    }
  ]

  environment_variables = {
    S3_BUCKET_NAME_SES       = module.ses_s3_bucket.s3_bucket_id
    S3_BUCKET_NAME_SNOWFLAKE = module.snowflake_s3_bucket.s3_bucket_id
  }

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    s3_ses = {
      effect  = "Allow",
      actions = ["s3:*"],
      resources = [
        "${module.ses_s3_bucket.s3_bucket_arn}/*",
        module.ses_s3_bucket.s3_bucket_arn,
      ]
    }
    s3_snowflake = {
      effect  = "Allow",
      actions = ["s3:Put*"],
      resources = [
        "${module.snowflake_s3_bucket.s3_bucket_arn}/*",
        module.snowflake_s3_bucket.s3_bucket_arn,
      ]
    }
    comprehend = {
      effect    = "Allow",
      actions   = ["comprehend:*"],
      resources = ["*"]
    }
  }

  allowed_triggers = {
    ScanAmiRule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.lambda_snowflake_schedule.arn
    }
  }

  cloudwatch_logs_retention_in_days = 3

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "lambda_snowflake_schedule" {
  name                = "${var.environment}_lambda_schedule"
  description         = "Trigger Lambda every 4 hours starting at midnight"
  schedule_expression = "cron(0 */4 * * ? *)"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_snowflake_target" {
  rule = aws_cloudwatch_event_rule.lambda_snowflake_schedule.name
  arn  = module.lambda_function_snowflake.lambda_function_arn
}