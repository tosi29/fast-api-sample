terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "api" {
  filename      = var.lambda_zip_path
  function_name = "${var.project_name}-${var.environment}-api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "src.lambda_handler.handler"
  runtime       = "python3.13"
  timeout       = 30
  memory_size   = 512

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project_name}-${var.environment}-api"
  description   = "FastAPI sample API"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age          = 0
  }
}

# API Gateway integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api.invoke_arn
}

# API Gateway route (catch all)
resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# API Gateway route for root path
resource "aws_apigatewayv2_route" "proxy_root" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      protocol       = "$context.protocol"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}-api"
  retention_in_days = 14
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}