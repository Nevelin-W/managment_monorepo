output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api.api_endpoint
}

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.auth.user_pool_id
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.auth.user_pool_client_id
  sensitive   = true
}

output "documents_bucket" {
  description = "S3 documents bucket name"
  value       = module.storage.documents_bucket_name
}

output "users_table" {
  description = "DynamoDB users table name"
  value       = module.database.users_table_name
}

output "subscriptions_table" {
  description = "DynamoDB subscriptions table name"
  value       = module.database.subscriptions_table_name
}