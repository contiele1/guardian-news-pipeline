data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../src/main.py"
  output_path = "${path.module}/../packages/function.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.12"
  layers           = [aws_lambda_layer_version.dependencies.arn]
}

