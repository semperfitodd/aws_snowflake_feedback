module "lambda_function_ses" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.environment}_ses_s3"
  description   = "${var.environment} function to put emails into S3"
  handler       = "app.lambda_handler"
  publish       = true
  runtime       = "python3.11"
  timeout       = 30

  source_path = [
    {
      path             = "${path.module}/lambda_ses"
      pip_requirements = false
    }
  ]

  environment_variables = {
    S3_BUCKET_NAME = module.ses_s3_bucket.s3_bucket_id
  }

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect  = "Allow",
      actions = ["s3:Put*"],
      resources = [
        "${module.ses_s3_bucket.s3_bucket_arn}/*",
        module.ses_s3_bucket.s3_bucket_arn,
      ]
    }
  }

  cloudwatch_logs_retention_in_days = 3

  tags = var.tags
}