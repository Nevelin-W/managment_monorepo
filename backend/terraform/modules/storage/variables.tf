variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "allowed_origins" {
  description = "Allowed CORS origins for the S3 bucket (used in prod)"
  type        = list(string)
  default     = ["https://example.com"]
}