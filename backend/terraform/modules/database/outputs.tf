output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "subscriptions_table_name" {
  value = aws_dynamodb_table.subscriptions.name
}

output "subscriptions_table_arn" {
  value = aws_dynamodb_table.subscriptions.arn
}

output "subscription_changes_table_name" {
  value = aws_dynamodb_table.subscription_changes.name
}

output "subscription_changes_table_arn" {
  value = aws_dynamodb_table.subscription_changes.arn
}