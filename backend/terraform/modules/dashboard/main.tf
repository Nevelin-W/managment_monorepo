locals {
  # Lambda function names for metric widgets
  fn = var.lambda_function_names

  # All auth function names
  auth_functions = [
    local.fn["auth_login"],
    local.fn["auth_signup"],
    local.fn["auth_me"],
    local.fn["auth_confirm"],
    local.fn["auth_resend_code"],
    local.fn["auth_update_profile"],
    local.fn["auth_change_password"],
  ]

  # All subscription function names
  subs_functions = [
    local.fn["subs_list"],
    local.fn["subs_create"],
    local.fn["subs_update"],
    local.fn["subs_delete"],
  ]

  all_functions = concat(local.auth_functions, local.subs_functions, [local.fn["email_processor"]])

  # Build the invocations metrics array for all functions
  invocations_metrics = [
    for name in local.all_functions : [
      "AWS/Lambda", "Invocations", "FunctionName", name,
      { stat = "Sum", label = name }
    ]
  ]

  # Build error metrics for all functions
  error_metrics = [
    for name in local.all_functions : [
      "AWS/Lambda", "Errors", "FunctionName", name,
      { stat = "Sum", label = name }
    ]
  ]

  # Build duration metrics for all functions
  duration_metrics = [
    for name in local.all_functions : [
      "AWS/Lambda", "Duration", "FunctionName", name,
      { stat = "Average", label = name }
    ]
  ]

  # Build throttle metrics for all functions
  throttle_metrics = [
    for name in local.all_functions : [
      "AWS/Lambda", "Throttles", "FunctionName", name,
      { stat = "Sum", label = name }
    ]
  ]

  # Log group names for Logs Insights queries
  log_group_names = [for name in local.all_functions : "/aws/lambda/${name}"]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [

      # ── Row 1: Overview numbers ──────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 6
        properties = {
          title   = "API Gateway Requests"
          region  = var.aws_region
          stat    = "Sum"
          period  = 300
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_name, "Stage", var.api_stage],
          ]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 6
        properties = {
          title   = "API Gateway 4xx Errors"
          region  = var.aws_region
          stat    = "Sum"
          period  = 300
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiName", var.api_name, "Stage", var.api_stage],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 6
        properties = {
          title   = "API Gateway 5xx Errors"
          region  = var.aws_region
          stat    = "Sum"
          period  = 300
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiName", var.api_name, "Stage", var.api_stage],
          ]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 6
        properties = {
          title   = "API Gateway Latency (avg)"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name, "Stage", var.api_stage],
            ["AWS/ApiGateway", "IntegrationLatency", "ApiName", var.api_name, "Stage", var.api_stage],
          ]
        }
      },

      # ── Row 2: Lambda invocations & errors ──────────────────
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Invocations"
          region  = var.aws_region
          period  = 300
          view    = "timeSeries"
          stacked = true
          metrics = local.invocations_metrics
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Errors"
          region  = var.aws_region
          period  = 300
          view    = "timeSeries"
          stacked = true
          metrics = local.error_metrics
        }
      },

      # ── Row 3: Duration & Throttles ─────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Duration (avg ms)"
          region  = var.aws_region
          period  = 300
          view    = "timeSeries"
          metrics = local.duration_metrics
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Throttles"
          region  = var.aws_region
          period  = 300
          view    = "timeSeries"
          metrics = local.throttle_metrics
        }
      },

      # ── Row 4: Logs Insights — Recent Errors ────────────────
      {
        type   = "log"
        x      = 0
        y      = 18
        width  = 24
        height = 6
        properties = {
          title   = "Recent Errors (all Lambdas)"
          region  = var.aws_region
          query   = "fields @timestamp, functionName, route, message, error\n| filter level = 'ERROR'\n| sort @timestamp desc\n| limit 50"
          view    = "table"
          stacked = false
          sources = local.log_group_names
        }
      },

      # ── Row 5: Logs Insights — Slow Requests ────────────────
      {
        type   = "log"
        x      = 0
        y      = 24
        width  = 12
        height = 6
        properties = {
          title   = "Slowest Requests (>1s)"
          region  = var.aws_region
          query   = "fields @timestamp, functionName, route, duration, statusCode\n| filter duration > 1000\n| sort duration desc\n| limit 25"
          view    = "table"
          stacked = false
          sources = local.log_group_names
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 24
        width  = 12
        height = 6
        properties = {
          title   = "Request Volume by Route"
          region  = var.aws_region
          query   = "fields route\n| filter level = 'INFO' and ispresent(statusCode)\n| stats count(*) as requests by route\n| sort requests desc"
          view    = "table"
          stacked = false
          sources = local.log_group_names
        }
      },

      # ── Row 6: Auth-specific metrics ────────────────────────
      {
        type   = "log"
        x      = 0
        y      = 30
        width  = 12
        height = 6
        properties = {
          title   = "Login Failures"
          region  = var.aws_region
          query   = "fields @timestamp, route, statusCode, message\n| filter route like /login/ and statusCode >= 400\n| sort @timestamp desc\n| limit 25"
          view    = "table"
          stacked = false
          sources = local.log_group_names
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 30
        width  = 12
        height = 6
        properties = {
          title   = "Response Status Distribution"
          region  = var.aws_region
          query   = "fields statusCode\n| filter ispresent(statusCode)\n| stats count(*) as count by statusCode\n| sort statusCode"
          view    = "bar"
          stacked = false
          sources = local.log_group_names
        }
      },
    ]
  })
}
