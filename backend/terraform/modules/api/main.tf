# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "Subscription Tracker API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.project_name}-cognito-authorizer-${var.environment}"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  provider_arns = [var.user_pool_arn]
}

# === AUTH ROUTES ===

# /auth resource
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "auth"
}

# /auth/login
resource "aws_api_gateway_resource" "auth_login" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "login"
}

module "auth_login_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_login.id
}

resource "aws_api_gateway_method" "auth_login_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_login" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_login.id
  http_method             = aws_api_gateway_method.auth_login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_login_arn
}

# /auth/signup
resource "aws_api_gateway_resource" "auth_signup" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "signup"
}

module "auth_signup_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_signup.id
}

resource "aws_api_gateway_method" "auth_signup_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_signup.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_signup" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_signup.id
  http_method             = aws_api_gateway_method.auth_signup_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_signup_arn
}

# /auth/me
resource "aws_api_gateway_resource" "auth_me" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "me"
}

module "auth_me_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_me.id
}

resource "aws_api_gateway_method" "auth_me_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_me.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "auth_me" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_me.id
  http_method             = aws_api_gateway_method.auth_me_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_me_arn
}

# /auth/profile (NEW - Update Profile)
resource "aws_api_gateway_resource" "auth_profile" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "profile"
}

module "auth_profile_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_profile.id
}

resource "aws_api_gateway_method" "auth_profile_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_profile.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "auth_profile" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_profile.id
  http_method             = aws_api_gateway_method.auth_profile_put.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_update_profile_invoke_arn
}

# /auth/change-password
resource "aws_api_gateway_resource" "auth_change_password" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "change-password"
}

module "auth_change_password_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_change_password.id
}

resource "aws_api_gateway_method" "auth_change_password_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_change_password.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "auth_change_password" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_change_password.id
  http_method             = aws_api_gateway_method.auth_change_password_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_change_password_invoke_arn
}


# /auth/confirm
resource "aws_api_gateway_resource" "auth_confirm" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "confirm"
}

module "auth_confirm_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_confirm.id
}

resource "aws_api_gateway_method" "auth_confirm_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_confirm.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_confirm" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_confirm.id
  http_method             = aws_api_gateway_method.auth_confirm_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_confirm_invoke_arn
}

# /auth/resend-code
resource "aws_api_gateway_resource" "auth_resend_code" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "resend-code"
}

module "auth_resend_code_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_resend_code.id
}

resource "aws_api_gateway_method" "auth_resend_code_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_resend_code.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_resend_code" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_resend_code.id
  http_method             = aws_api_gateway_method.auth_resend_code_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_auth_resend_code_invoke_arn
}

# === SUBSCRIPTION ROUTES ===

# /subscriptions
resource "aws_api_gateway_resource" "subscriptions" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "subscriptions"
}

module "subscriptions_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.subscriptions.id
}

resource "aws_api_gateway_method" "subs_list_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.subscriptions.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "subs_list" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.subscriptions.id
  http_method             = aws_api_gateway_method.subs_list_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_subs_list_arn
}

resource "aws_api_gateway_method" "subs_create_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.subscriptions.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "subs_create" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.subscriptions.id
  http_method             = aws_api_gateway_method.subs_create_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_subs_create_arn
}

# /subscriptions/{id}
resource "aws_api_gateway_resource" "subscription_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.subscriptions.id
  path_part   = "{id}"
}

module "subscription_id_cors" {
  source      = "../api_cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.subscription_id.id
}

resource "aws_api_gateway_method" "subs_update_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.subscription_id.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "subs_update" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.subscription_id.id
  http_method             = aws_api_gateway_method.subs_update_put.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_subs_update_arn
}

resource "aws_api_gateway_method" "subs_delete_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.subscription_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "subs_delete" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.subscription_id.id
  http_method             = aws_api_gateway_method.subs_delete_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_subs_delete_arn
}

# Lambda Permissions
resource "aws_lambda_permission" "api_gateway" {
  for_each = {
    auth_login           = { function_name = var.lambda_auth_login_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    auth_signup          = { function_name = var.lambda_auth_signup_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    auth_me              = { function_name = var.lambda_auth_me_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    auth_profile         = { function_name = var.lambda_auth_update_profile_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    auth_confirm         = { function_name = var.lambda_auth_confirm_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    auth_change_password = { function_name = var.lambda_auth_change_password_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    auth_resend_code     = { function_name = var.lambda_auth_resend_code_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    subs_list            = { function_name = var.lambda_subs_list_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    subs_create          = { function_name = var.lambda_subs_create_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    subs_update          = { function_name = var.lambda_subs_update_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
    subs_delete          = { function_name = var.lambda_subs_delete_name, source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*" }
  }

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = each.value.source_arn
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  triggers = {
    redeployment = sha1(jsonencode({
      resources = [
        aws_api_gateway_resource.auth.id,
      aws_api_gateway_resource.subscriptions.id,
      aws_api_gateway_method.auth_login_post.id,
      aws_api_gateway_method.auth_signup_post.id,
      aws_api_gateway_method.auth_me_get.id,
      aws_api_gateway_method.auth_profile_put.id,
      aws_api_gateway_method.auth_change_password_post.id,
      aws_api_gateway_method.auth_confirm_post.id,
      aws_api_gateway_method.auth_resend_code_post.id,
      aws_api_gateway_method.subs_list_get.id,
      aws_api_gateway_method.subs_create_post.id,
      aws_api_gateway_method.subs_update_put.id,
      aws_api_gateway_method.subs_delete_delete.id,
      aws_api_gateway_integration.auth_login.id,
      aws_api_gateway_integration.auth_signup.id,
      aws_api_gateway_integration.auth_me.id,
      aws_api_gateway_integration.auth_profile.id,
      aws_api_gateway_integration.auth_confirm.id,
      aws_api_gateway_integration.auth_resend_code.id,
      aws_api_gateway_integration.auth_change_password.id,
      aws_api_gateway_integration.subs_list.id,
      aws_api_gateway_integration.subs_create.id,
      aws_api_gateway_integration.subs_update.id,
      aws_api_gateway_integration.subs_delete.id,
      module.auth_login_cors,
      module.auth_signup_cors,
      module.auth_me_cors,
      module.auth_profile_cors,
      module.auth_confirm_cors,
      module.auth_resend_code_cors,
      module.auth_change_password_cors,
      module.subscriptions_cors,
      module.subscription_id_cors,
      ]
      lambda_hashes = {
        update_profile = var.auth_confirm_source_code_hash
      }
    }))
  }
  

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.auth_login,
    aws_api_gateway_integration.auth_signup,
    aws_api_gateway_integration.auth_me,
    aws_api_gateway_integration.auth_profile,
    aws_api_gateway_integration.auth_confirm,
    aws_api_gateway_integration.auth_resend_code,
    aws_api_gateway_integration.auth_change_password,
    aws_api_gateway_integration.subs_list,
    aws_api_gateway_integration.subs_create,
    aws_api_gateway_integration.subs_update,
    aws_api_gateway_integration.subs_delete,
    module.auth_login_cors,
    module.auth_signup_cors,
    module.auth_me_cors,
    module.auth_profile_cors,
    module.auth_confirm_cors,
    module.auth_resend_code_cors,
    module.auth_change_password_cors,
    module.subscriptions_cors,
    module.subscription_id_cors,
  ]
}

# API Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.environment == "prod" ? 30 : 7
}

# Enable CloudWatch Metrics
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = var.environment == "dev"
  }
}

# Gateway Response for CORS
resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  response_type = "UNAUTHORIZED"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}
