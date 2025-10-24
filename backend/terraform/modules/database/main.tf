# DynamoDB Table - Users
resource "aws_dynamodb_table" "users" {
  name         = "${var.project_name}-users-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"  # Cost-optimized: pay only for what you use
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }

  global_secondary_index {
    name            = "IdIndex"
    hash_key        = "id"
    projection_type = "ALL"
  }

  ttl {
    enabled        = false
    attribute_name = ""
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = {
    Name = "${var.project_name}-users-${var.environment}"
  }
}

# DynamoDB Table - Subscriptions
resource "aws_dynamodb_table" "subscriptions" {
  name         = "${var.project_name}-subscriptions-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "user_id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "next_billing_date"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIndex"
    hash_key        = "user_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "BillingDateIndex"
    hash_key        = "user_id"
    range_key       = "next_billing_date"
    projection_type = "ALL"
  }

  ttl {
    enabled        = false
    attribute_name = ""
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = {
    Name = "${var.project_name}-subscriptions-${var.environment}"
  }
}

# DynamoDB Table - Subscription Change Log
resource "aws_dynamodb_table" "subscription_changes" {
  name         = "${var.project_name}-subscription-changes-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "subscription_id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "subscription_id"
    type = "S"
  }

  attribute {
    name = "detected_at"
    type = "S"
  }

  global_secondary_index {
    name            = "SubscriptionIndex"
    hash_key        = "subscription_id"
    range_key       = "detected_at"
    projection_type = "ALL"
  }

  ttl {
    enabled        = true
    attribute_name = "ttl"  # Auto-delete old change logs after 90 days
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = {
    Name = "${var.project_name}-subscription-changes-${var.environment}"
  }
}