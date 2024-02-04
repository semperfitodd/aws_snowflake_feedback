module "lambda_function_ses" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.environment}_ses_s3"
  description   = "${var.environment} function to put emails into S3"
  handler       = "index.handler"
  publish       = true
  runtime       = "nodejs16.x"
  timeout       = 30

  source_path = [
    {
      npm_requirements = true
      path             = "${path.module}/lambda_ses"
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

resource "null_resource" "npm_install_ses" {
  triggers = {
    package_json        = filesha256("${path.module}/lambda_ses/package.json")
    node_modules_exists = length(fileset("${path.module}/lambda_ses", "node_modules/**")) > 0 ? "true" : "false"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda_ses && npm install"
  }
}
