output "iam_role_arn" {
  value = length(aws_iam_role.role) == 1 ? aws_iam_role.role[0].arn : var.function_role
}

output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "lambda_version" {
  value = aws_lambda_function.lambda.version
}
