# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool-${var.environment}"

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Auto-verified attributes
  auto_verified_attributes = ["email"]

  # Email verification message
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verify your email - ${var.project_name}"
    email_message        = <<-EOT
      <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0;">Welcome to ${var.project_name}!</h1>
          </div>
          <div style="background: #f7fafc; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 16px; color: #2d3748; margin-bottom: 20px;">
              Thank you for signing up! Please verify your email address to complete your registration.
            </p>
            <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0;">
              <p style="font-size: 14px; color: #718096; margin-bottom: 10px;">Your verification code:</p>
              <h2 style="font-size: 32px; color: #667eea; letter-spacing: 5px; margin: 10px 0;">{####}</h2>
            </div>
            <p style="font-size: 14px; color: #718096; margin-top: 30px;">
              This code will expire in 24 hours. If you didn't sign up for ${var.project_name}, please ignore this email.
            </p>
          </div>
          <div style="text-align: center; padding: 20px; color: #a0aec0; font-size: 12px;">
            <p>© ${formatdate("YYYY", timestamp())} ${var.project_name}. All rights reserved.</p>
          </div>
        </body>
      </html>
    EOT
  }

  # User attribute schema
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable            = true
    required           = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable            = true
    required           = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Name = "${var.project_name}-user-pool-${var.environment}"
    Environment = "${var.environment}"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  # Token validity
  access_token_validity  = 1  # 1 hour
  id_token_validity      = 1  # 1 hour
  refresh_token_validity = 30 # 30 days

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # OAuth flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read/Write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name"
  ]

  write_attributes = [
    "email",
    "name"
  ]
}

# Cognito User Pool Domain (optional, for hosted UI)
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}