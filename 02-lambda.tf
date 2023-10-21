data "archive_file" "source" {
  count       = var.source_dir == null ? 0 : 1
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.root}/files/out-${random_id.unique.id}.zip"
}

# Definição do lambda
resource "aws_lambda_function" "lambda" {
  function_name = var.function_name

  role = length(aws_iam_role.role) == 1 ? aws_iam_role.role[0].arn : var.function_role

  runtime = var.runtime
  handler = var.handler

  # Some attributes
  memory_size = var.memory_size
  timeout     = var.timeout
  description = var.description
  publish     = var.publish

  layers = []

  ###############
  # Source Code
  source_code_hash = local.source_code_hash
  package_type     = local.package_type

  # via S3
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  # via File name
  filename = var.source_dir == null ? null : data.archive_file.source[0].output_path

  # Variaveis de ambiente
  dynamic "environment" {
    for_each = var.environment_variables == null ? [] : [var.environment_variables]
    content {
      variables = var.environment_variables
    }
  }
  #environment {
  #  variables = var.environment_variables
  #}

  # VPC Config
  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  depends_on = [aws_cloudwatch_log_group.this, aws_s3_bucket.bucket]

  tags = {
    "iac" = "terraform"
  }

  lifecycle {
    ignore_changes = [environment]
  }
}

## Criar o log group do cloudwatch
resource "aws_cloudwatch_log_group" "this" {
  name              = format("/aws/lambda/%s", var.function_name)
  retention_in_days = var.log_retention

  tags = {
    function = var.function_name
  }
}
