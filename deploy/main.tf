# Define the AWS provider with the specified region
provider "aws" {
  region = "eu-west-2"
  access_key = "****"
  secret_key = "****"
  
}

# Create an IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"

  # Assume role policy allowing Lambda service to assume this role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Define the Lambda function
resource "aws_lambda_function" "python_lambda" {
  function_name    = "PythonLambdaFunction"
  runtime          = "python3.8"
  handler          = "lambda.lambda_handler" #Lambda script's entry point
  memory_size      = 256
  timeout          = 10
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = "./deploy/lambda_function_api.zip" # Update the path accordingly
}


resource "aws_api_gateway_rest_api" "flask_api_gateway" {
  name        = "FlaskAPIGateway"
  description = "API Gateway for Flask API"
}

resource "aws_api_gateway_resource" "flask_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.flask_api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "flask_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.flask_api_gateway.id
  resource_id   = aws_api_gateway_resource.flask_api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "flask_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  resource_id = aws_api_gateway_resource.flask_api_resource.id
  http_method = aws_api_gateway_method.flask_api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.python_lambda.invoke_arn
}

resource "aws_lambda_permission" "flask_api_lambda_permission" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.python_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.flask_api_gateway.execution_arn}/*/*"
}

# Add a resource for /power/europe
resource "aws_api_gateway_resource" "flask_api_power_europe" {
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  parent_id   = aws_api_gateway_resource.flask_api_resource.id
  path_part   = "power"
}

resource "aws_api_gateway_resource" "flask_api_power_europe_subresource" {
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  parent_id   = aws_api_gateway_resource.flask_api_power_europe.id
  path_part   = "europe"
}

resource "aws_api_gateway_method" "flask_api_power_europe_method" {
  rest_api_id   = aws_api_gateway_rest_api.flask_api_gateway.id
  resource_id   = aws_api_gateway_resource.flask_api_power_europe_subresource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "flask_api_power_europe_integration" {
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  resource_id = aws_api_gateway_resource.flask_api_power_europe_subresource.id
  http_method = aws_api_gateway_method.flask_api_power_europe_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.python_lambda.invoke_arn
}

# Optionally, you can add a deployment for your API
resource "aws_api_gateway_deployment" "flask_api_deployment" {
  depends_on      = [aws_api_gateway_integration.flask_api_integration, aws_api_gateway_integration.flask_api_power_europe_integration]
  rest_api_id      = aws_api_gateway_rest_api.flask_api_gateway.id
  stage_name       = "prod"
}