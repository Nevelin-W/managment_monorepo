# EventBridge Rule for scheduled email checking
resource "aws_cloudwatch_event_rule" "email_check" {
  name                = "${var.project_name}-email-check-${var.environment}"
  description         = "Trigger email processor Lambda on schedule"
  schedule_expression = var.email_check_schedule
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "email_processor" {
  rule      = aws_cloudwatch_event_rule.email_check.name
  target_id = "EmailProcessorLambda"
  arn       = var.email_processor_lambda_arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.email_processor_lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.email_check.arn
}

# S3 Event Notification (optional - for email attachments uploaded directly)
# resource "aws_s3_bucket_notification" "email_uploads" {
#   bucket = var.documents_bucket_id

#   lambda_function {
#     lambda_function_arn = var.email_processor_lambda_arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "emails/incoming/"
#   }

#   depends_on = [aws_lambda_permission.allow_s3]
# }

# Lambda Permission for S3
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = var.email_processor_lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.documents_bucket_arn
}