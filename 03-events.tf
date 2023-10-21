## SQS Event
resource "aws_lambda_event_source_mapping" "ev_sqs" {
  count = var.event_type == "sqs" ? 1 : 0

  event_source_arn = var.event_sqs_arn
  function_name    = aws_lambda_function.lambda.arn
}

## DynamoDB
resource "aws_lambda_event_source_mapping" "ev_dynamodb" {
  count = var.event_type == "dynamodb" ? 1 : 0

  event_source_arn  = var.event_dynamodb_arn
  function_name     = aws_lambda_function.lambda.arn
  starting_position = "LATEST"
}
