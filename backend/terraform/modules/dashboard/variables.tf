variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "api_name" {
  description = "API Gateway REST API name"
  type        = string
}

variable "api_stage" {
  description = "API Gateway stage name"
  type        = string
}

variable "lambda_function_names" {
  description = "Map of logical name to Lambda function name"
  type        = map(string)
}
