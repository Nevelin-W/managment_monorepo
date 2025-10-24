variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "email_processor_lambda_arn" {
  description = "Email processor Lambda ARN"
  type        = string
}

variable "documents_bucket_arn" {
  description = "Documents S3 bucket ARN"
  type        = string
}

variable "documents_bucket_id" {
  description = "Documents S3 bucket ID"
  type        = string
  default     = ""
}

variable "email_check_schedule" {
  description = "EventBridge schedule expression"
  type        = string
  default     = "rate(6 hours)"
}