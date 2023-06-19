output "lambda-role-name" {
  value = aws_iam_role.lambdaRole.arn
}

output "lambda-bot-invocation-url" {
  value = aws_lambda_function_url.bot-lambda-invocation-url.function_url
}

output "api-gw-integration-uri" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}