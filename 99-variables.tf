###############
## Data
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_policy" "policyLambdaVPCAccess" {
  name = "AWSLambdaVPCAccessExecutionRole"
}

resource "random_id" "unique" {
  byte_length = 8
}

################
## Locals
locals {
  source_code_hash = var.source_dir != null ? filebase64sha256(data.archive_file.source[0].output_path) : null
  package_type     = var.source_dir != null ? "Zip" : var.package_type
}

################
## Variables
variable "function_name" {
  type        = string
  nullable    = false
  description = "Nome da função"
}

variable "package_type" {
  type    = string
  default = null
}

variable "timeout" {
  type        = number
  default     = 2
  description = "Timeout of the run. Defaults to 2"
}

variable "description" {
  type        = string
  nullable    = false
  description = "Description of your Lambda function"
}

variable "function_role" {
  type        = string
  description = "Role ARN. Deixar em branco para criar uma nova"
  default     = null
}

variable "runtime" {
  type        = string
  description = "Runtime to run this lambda"
  nullable    = false
}

variable "handler" {
  type        = string
  description = "Point of entry to run this lambda function"
  nullable    = false
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
  default     = 128
}

variable "filename" {
  type    = string
  default = null
}

variable "environment_variables" {
  type    = map(any)
  default = null
}

variable "publish" {
  type    = bool
  default = false
}

variable "role_permissions" {
  type        = list(string)
  description = "Lista de permissões adicionais para a role nova"
  default     = []

  validation {
    condition = alltrue([
      for perm in var.role_permissions : can(regex("^([a-zA-Z]).*:([a-zA-Z]).*", perm))
    ])
    error_message = "Atributo role_permissions inválido. Só é permitido caracteres de a-zA-Z, no formato service:action."
  }
}

variable "vpc_config" {
  default     = null
  description = ""
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}

variable "log_retention" {
  type        = number
  description = "Dias em que deseja reter logs no cloudwatch. Default = 5"
  default     = 5

  validation {
    condition     = var.log_retention >= 0
    error_message = "Valor deve ser >= 0."
  }
}

variable "source_dir" {
  type    = string
  default = null
}

###################
## S3 location
variable "s3_bucket" {
  type    = string
  default = null
}
variable "s3_key" {
  type    = string
  default = null
}
variable "s3_object_version" {
  type    = string
  default = null
}
variable "s3_create_upload" {
  type        = bool
  default     = false
  description = "Indica a criação de um bucket para guardar o código. Utilizar a variável s3_src_dir em conjunto."
}

###########################
### Events source
variable "event_type" {
  type        = string
  description = "Escolha entre: sqs"
  default     = null

  validation {
    condition = (
      var.event_type == null ? true :
      contains(["sqs", "dynamodb"], var.event_type)
    )
    error_message = "Valor não é valido."
  }
}

variable "event_sqs_arn" {
  type        = string
  description = "ARN do SQS"
  default     = null
}

variable "event_dynamodb_arn" {
  type        = string
  description = "ARN DynamoDB Table"
  default     = null
}
