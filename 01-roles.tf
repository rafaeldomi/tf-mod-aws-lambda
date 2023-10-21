# Criar a role condicionalmente
resource "aws_iam_role" "role" {
  # Se não foi preenchido a variável, cria a role
  count = var.function_role == null ? 1 : 0

  # RL = Role Lambda
  name = "RL-${var.function_name}-${random_id.unique.id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "InitialLambdaPermission"
    }
  ]
}
EOF

  tags = {
    "iac" = "terraform"
  }
}

## Definições de Policies
resource "aws_iam_role_policy" "iampolicy" {
  count = var.function_role == null ? length(var.role_permissions) : 0

  name = join("", ["InlinePolicy-", replace(var.role_permissions[count.index], ":", "_")])
  role = aws_iam_role.role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
          "Sid": "InlinePolicy${replace(var.role_permissions[count.index], ":", "")}",
            "Effect": "Allow",
            "Action": "${var.role_permissions[count.index]}",
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iampolicy_basiclambda" {
  count = var.function_role == null ? 1 : 0

  name = "AWSLambdaBasicExecutionRole-${random_id.unique.id}"
  role = aws_iam_role.role[0].id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/${var.function_name}:*"
            ]
        }
    ]
}
EOF
}

## Attach Policy AWSLambdaVPCAccessExecutionRole caso tenha informado VPC
resource "aws_iam_role_policy_attachment" "rpa_vpc" {
  count = var.vpc_config == null ? 0 : 1

  role       = aws_iam_role.role[0].id
  policy_arn = data.aws_iam_policy.policyLambdaVPCAccess.arn
}
