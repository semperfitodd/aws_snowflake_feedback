module "lambda_function_front_end" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.environment}_front_end"
  description   = "${var.environment} function to access Snowflake"

  handler = "index.handler"
  publish = true
  runtime = "nodejs16.x"
  timeout = 30

  source_path = [
    {
      path             = "${path.module}/lambda_front_end"
      npm_requirements = true

    }
  ]

  attach_policies = true
  policies        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  attach_policy_statements = true
  policy_statements = {
    secrets = {
      effect = "Allow",
      actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
      ],
      resources = [aws_secretsmanager_secret.snowflake_secret.arn]
    }
  }

  environment_variables = {
    SECRET_NAME = aws_secretsmanager_secret.snowflake_secret.name
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  cloudwatch_logs_retention_in_days = 3

  layers = ["arn:aws:lambda:${var.region}:580247275435:layer:LambdaInsightsExtension-Arm64:5"] # x-ray

  tags = var.tags
}

resource "aws_secretsmanager_secret" "snowflake_secret" {
  name                    = "${local.environment}-snowflake-credentials"
  description             = "${local.environment} snowflake secrets"
  recovery_window_in_days = "7"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "snowflake_secret" {
  secret_id = aws_secretsmanager_secret.snowflake_secret.id
  secret_string = jsonencode(
    {
      account  = null
      password = null
      username = null
    }
  )

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "null_resource" "npm_install_front_end" {
  triggers = {
    package_json        = filesha256("${path.module}/lambda_front_end/package.json")
    node_modules_exists = length(fileset("${path.module}/lambda_front_end", "node_modules/**")) > 0 ? "true" : "false"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda_ses && npm install"
  }
}