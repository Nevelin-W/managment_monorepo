variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "user_pool_arn" {
  description = "Cognito User Pool ARN"
  type        = string
}

variable "lambda_auth_login_arn" {
  description = "Auth login Lambda invoke ARN"
  type        = string
}

variable "lambda_auth_signup_arn" {
  description = "Auth signup Lambda invoke ARN"
  type        = string
}

variable "lambda_auth_me_arn" {
  description = "Auth me Lambda invoke ARN"
  type        = string
}

variable "lambda_subs_list_arn" {
  description = "Subscriptions list Lambda invoke ARN"
  type        = string
}

variable "lambda_subs_create_arn" {
  description = "Subscriptions create Lambda invoke ARN"
  type        = string
}

variable "lambda_subs_update_arn" {
  description = "Subscriptions update Lambda invoke ARN"
  type        = string
}

variable "lambda_subs_delete_arn" {
  description = "Subscriptions delete Lambda invoke ARN"
  type        = string
}

variable "lambda_auth_login_name" {
  description = "Auth login Lambda function name"
  type        = string
}

variable "lambda_auth_signup_name" {
  description = "Auth signup Lambda function name"
  type        = string
}

variable "lambda_auth_me_name" {
  description = "Auth me Lambda function name"
  type        = string
}

variable "lambda_auth_confirm_name" {
  description = "Auth confirm Lambda function name"
  type        = string
}
variable "lambda_auth_confirm_invoke_arn" {
  description = "Auth confirm Lambda invoke ARN"
  type        = string
}

variable "lambda_auth_resend_code_name" {
  description = "Auth resend code Lambda function name"
  type        = string
}
variable "lambda_auth_resend_code_invoke_arn" {
  description = "Auth resend code Lambda invoke ARN"
  type        = string
}

variable "lambda_subs_list_name" {
  description = "Subscriptions list Lambda function name"
  type        = string
}

variable "lambda_subs_create_name" {
  description = "Subscriptions create Lambda function name"
  type        = string
}

variable "lambda_subs_update_name" {
  description = "Subscriptions update Lambda function name"
  type        = string
}

variable "lambda_subs_delete_name" {
  description = "Subscriptions delete Lambda function name"
  type        = string
}