# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB access policy
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      Resource = [
        "arn:aws:dynamodb:*:*:table/${var.users_table_name}",
        "arn:aws:dynamodb:*:*:table/${var.users_table_name}/*",
        "arn:aws:dynamodb:*:*:table/${var.subscriptions_table}",
        "arn:aws:dynamodb:*:*:table/${var.subscriptions_table}/*"
      ]
    }]
  })
}

# S3 access policy
resource "aws_iam_role_policy" "lambda_s3" {
  name = "${var.project_name}-lambda-s3-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = "arn:aws:s3:::${var.documents_bucket}/*"
    }]
  })
}

# Cognito access policy
resource "aws_iam_role_policy" "lambda_cognito" {
  name = "${var.project_name}-lambda-cognito-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminConfirmSignUp",
          "cognito-idp:AdminUpdateUserAttributes"

        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda Layer for shared dependencies
resource "aws_lambda_layer_version" "dependencies" {
  filename            = "${path.module}/../../lambda_functions/layers/dependencies.zip"
  layer_name          = "${var.project_name}-dependencies-${var.environment}"
  compatible_runtimes = ["nodejs20.x"]
  
  lifecycle {
    create_before_destroy = true
  }
}

# Auth - Login Lambda
resource "aws_lambda_function" "auth_login" {
  filename      = "${path.module}/../../lambda_functions/auth/login/function.zip"
  function_name = "${var.project_name}-auth-login-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      USER_POOL_ID        = var.user_pool_id
      USER_POOL_CLIENT_ID = var.user_pool_client_id
      USERS_TABLE         = var.users_table_name
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Auth - Signup Lambda
resource "aws_lambda_function" "auth_signup" {
  filename      = "${path.module}/../../lambda_functions/auth/signup/function.zip"
  function_name = "${var.project_name}-auth-signup-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      USER_POOL_ID        = var.user_pool_id
      USER_POOL_CLIENT_ID = var.user_pool_client_id
      USERS_TABLE         = var.users_table_name
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Auth - Get Me Lambda
resource "aws_lambda_function" "auth_me" {
  filename      = "${path.module}/../../lambda_functions/auth/me/function.zip"
  function_name = "${var.project_name}-auth-me-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      USERS_TABLE = var.users_table_name
      ENVIRONMENT = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Auth - Confirm Email Lambda
resource "aws_lambda_function" "auth_confirm" {
  filename      = "${path.module}/../../lambda_functions/auth/confirm_signup/function.zip"
  function_name = "${var.project_name}-auth-confirm-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      USER_POOL_ID        = var.user_pool_id
      USER_POOL_CLIENT_ID = var.user_pool_client_id
      USERS_TABLE         = var.users_table_name
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Auth - Resend Code Lambda
resource "aws_lambda_function" "auth_resend_code" {
  filename      = "${path.module}/../../lambda_functions/auth/resend_code/function.zip"
  function_name = "${var.project_name}-auth-resend-code-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 128

  environment {
    variables = {
      USER_POOL_CLIENT_ID = var.user_pool_client_id
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Auth - Change Password Lambda
resource "aws_lambda_function" "auth_change_password" {
  filename      = "${path.module}/../../lambda_functions/auth/change_password/function.zip"
  function_name = "${var.project_name}-auth-change-password-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      USER_POOL_ID        = var.user_pool_id
      USER_POOL_CLIENT_ID = var.user_pool_client_id
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

resource "aws_lambda_function" "auth_update_profile" {
  filename      = "${path.module}/../../lambda_functions/auth/update_profile/function.zip"
  function_name = "${var.project_name}-auth-update-profile-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      USER_POOL_ID        = var.user_pool_id
      USER_POOL_CLIENT_ID = var.user_pool_client_id
      USERS_TABLE         = var.users_table_name
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Add to CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = {
    auth_login         = aws_lambda_function.auth_login.function_name
    auth_signup        = aws_lambda_function.auth_signup.function_name
    auth_me            = aws_lambda_function.auth_me.function_name
    auth_update_profile = aws_lambda_function.auth_update_profile.function_name
    auth_change_password = aws_lambda_function.auth_change_password.function_name
    subs_list          = aws_lambda_function.subs_list.function_name
    subs_create        = aws_lambda_function.subs_create.function_name
    subs_update        = aws_lambda_function.subs_update.function_name
    subs_delete        = aws_lambda_function.subs_delete.function_name
    email_processor    = aws_lambda_function.email_processor.function_name
    auth_confirm_logs  = aws_lambda_function.auth_confirm.function_name
    auth_resend_code_logs = aws_lambda_function.auth_resend_code.function_name
  }

  name              = "/aws/lambda/${each.value}"
  retention_in_days = var.environment == "prod" ? 30 : 7
}

# Subscriptions - List Lambda
resource "aws_lambda_function" "subs_list" {
  filename      = "${path.module}/../../lambda_functions/subscriptions/list/function.zip"
  function_name = "${var.project_name}-subs-list-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      SUBSCRIPTIONS_TABLE = var.subscriptions_table
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Subscriptions - Create Lambda
resource "aws_lambda_function" "subs_create" {
  filename      = "${path.module}/../../lambda_functions/subscriptions/create/function.zip"
  function_name = "${var.project_name}-subs-create-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      SUBSCRIPTIONS_TABLE = var.subscriptions_table
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Subscriptions - Update Lambda
resource "aws_lambda_function" "subs_update" {
  filename      = "${path.module}/../../lambda_functions/subscriptions/update/function.zip"
  function_name = "${var.project_name}-subs-update-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      SUBSCRIPTIONS_TABLE = var.subscriptions_table
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Subscriptions - Delete Lambda
resource "aws_lambda_function" "subs_delete" {
  filename      = "${path.module}/../../lambda_functions/subscriptions/delete/function.zip"
  function_name = "${var.project_name}-subs-delete-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      SUBSCRIPTIONS_TABLE = var.subscriptions_table
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Email Processor Lambda
resource "aws_lambda_function" "email_processor" {
  filename      = "${path.module}/../../lambda_functions/email_processor/function.zip"
  function_name = "${var.project_name}-email-processor-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 300  # 5 minutes for email processing
  memory_size   = 512

  environment {
    variables = {
      SUBSCRIPTIONS_TABLE = var.subscriptions_table
      DOCUMENTS_BUCKET    = var.documents_bucket
      ENVIRONMENT         = var.environment
    }
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# # CloudWatch Log Groups
# resource "aws_cloudwatch_log_group" "lambda_logs" {
#   for_each = {
#     auth_login      = aws_lambda_function.auth_login.function_name
#     auth_signup     = aws_lambda_function.auth_signup.function_name
#     auth_me         = aws_lambda_function.auth_me.function_name
#     auth_update_profile = aws_lambda_function.auth_update_profile.function_name
#     subs_list       = aws_lambda_function.subs_list.function_name
#     subs_create     = aws_lambda_function.subs_create.function_name
#     subs_update     = aws_lambda_function.subs_update.function_name
#     subs_delete     = aws_lambda_function.subs_delete.function_name
#     email_processor = aws_lambda_function.email_processor.function_name
#     auth_confirm_logs = aws_lambda_function.auth_confirm.function_name
#     auth_resend_code_logs = aws_lambda_function.auth_resend_code.function_name
#   }

#   name              = "/aws/lambda/${each.value}"
#   retention_in_days = var.environment == "prod" ? 30 : 7
# }