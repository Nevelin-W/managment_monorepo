variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "subtrack"
}

# DynamoDB Settings
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# Lambda Settings
variable "lambda_runtime" {
  description = "Runtime environment for AWS Lambda"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_memory_size" {
  description = "Memory size for AWS Lambda (MB)"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout for AWS Lambda (seconds)"
  type        = number
  default     = 30
}

# S3 Settings
variable "s3_lifecycle_days" {
  description = "Number of days before deleting temporary S3 files"
  type        = number
  default     = 7
}

# CloudWatch Settings
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

# Email Processing Schedule
variable "email_check_schedule" {
  description = "Schedule expression for checking emails"
  type        = string
  default     = "rate(6 hours)"
}