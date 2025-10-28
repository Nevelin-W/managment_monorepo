terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Database Module
module "database" {
  source = "../../modules/database"

  environment  = var.environment
  project_name = var.project_name
}

# Auth Module (Cognito)
module "auth" {
  source = "../../modules/auth"

  environment  = var.environment
  project_name = var.project_name
}

# Storage Module (S3)
module "storage" {
  source = "../../modules/storage"

  environment  = var.environment
  project_name = var.project_name
}

# Lambda Functions Module
module "lambda" {
  source = "../../modules/lambda"

  environment         = var.environment
  project_name        = var.project_name
  users_table_name    = module.database.users_table_name
  subscriptions_table = module.database.subscriptions_table_name
  documents_bucket    = module.storage.documents_bucket_name
  user_pool_id        = module.auth.user_pool_id
  user_pool_client_id = module.auth.user_pool_client_id
}

# API Gateway Module
module "api" {
  source = "../../modules/api"

  environment                        = var.environment
  project_name                       = var.project_name
  lambda_auth_login_arn              = module.lambda.auth_login_invoke_arn
  lambda_auth_signup_arn             = module.lambda.auth_signup_invoke_arn
  lambda_auth_me_arn                 = module.lambda.auth_me_invoke_arn
  lambda_subs_list_arn               = module.lambda.subs_list_invoke_arn
  lambda_subs_create_arn             = module.lambda.subs_create_invoke_arn
  lambda_subs_update_arn             = module.lambda.subs_update_invoke_arn
  lambda_subs_delete_arn             = module.lambda.subs_delete_invoke_arn
  lambda_auth_login_name             = module.lambda.auth_login_name
  lambda_auth_signup_name            = module.lambda.auth_signup_name
  lambda_auth_me_name                = module.lambda.auth_me_name
  lambda_auth_confirm_name           = module.lambda.auth_confirm_name
  lambda_auth_confirm_invoke_arn     = module.lambda.auth_confirm_invoke_arn
  lambda_auth_resend_code_name       = module.lambda.auth_resend_code_name
  lambda_auth_resend_code_invoke_arn = module.lambda.auth_resend_code_invoke_arn
  lambda_subs_list_name              = module.lambda.subs_list_name
  lambda_subs_create_name            = module.lambda.subs_create_name
  lambda_subs_update_name            = module.lambda.subs_update_name
  lambda_subs_delete_name            = module.lambda.subs_delete_name
  user_pool_arn                      = module.auth.user_pool_arn
}

# Email Processing Module
module "email" {
  source = "../../modules/email"

  environment                = var.environment
  project_name               = var.project_name
  email_processor_lambda_arn = module.lambda.email_processor_arn
  documents_bucket_arn       = module.storage.documents_bucket_arn
}
