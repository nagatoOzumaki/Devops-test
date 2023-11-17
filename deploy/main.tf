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
  handler          = "lambda.lambda_handler" 
  memory_size      = 256
  timeout          = 10
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = "lambda_function.zip"
}
