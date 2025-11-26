output "auth_login_invoke_arn" {
  value = aws_lambda_function.auth_login.invoke_arn
}

output "auth_login_name" {
  value = aws_lambda_function.auth_login.function_name
}

output "auth_signup_invoke_arn" {
  value = aws_lambda_function.auth_signup.invoke_arn
}

output "auth_signup_name" {
  value = aws_lambda_function.auth_signup.function_name
}

output "auth_me_invoke_arn" {
  value = aws_lambda_function.auth_me.invoke_arn
}

output "auth_confirm_name" {
  value = aws_lambda_function.auth_confirm.function_name
}

output "auth_confirm_invoke_arn" {
  value = aws_lambda_function.auth_confirm.invoke_arn
  
}

output "auth_resend_code_name" {
  value = aws_lambda_function.auth_resend_code.function_name
}

output "auth_resend_code_invoke_arn" {
  value = aws_lambda_function.auth_resend_code.invoke_arn
}

output "auth_me_name" {
  value = aws_lambda_function.auth_me.function_name
}

output "subs_list_invoke_arn" {
  value = aws_lambda_function.subs_list.invoke_arn
}

output "subs_list_name" {
  value = aws_lambda_function.subs_list.function_name
}

output "subs_create_invoke_arn" {
  value = aws_lambda_function.subs_create.invoke_arn
}

output "subs_create_name" {
  value = aws_lambda_function.subs_create.function_name
}

output "subs_update_invoke_arn" {
  value = aws_lambda_function.subs_update.invoke_arn
}

output "subs_update_name" {
  value = aws_lambda_function.subs_update.function_name
}

output "subs_delete_invoke_arn" {
  value = aws_lambda_function.subs_delete.invoke_arn
}

output "subs_delete_name" {
  value = aws_lambda_function.subs_delete.function_name
}

output "email_processor_arn" {
  value = aws_lambda_function.email_processor.arn
}

output "email_processor_name" {
  value = aws_lambda_function.email_processor.function_name
}

output "auth_update_profile_function" {
  description = "Auth update profile Lambda function"
  value = {
    arn           = aws_lambda_function.auth_update_profile.arn
    function_name = aws_lambda_function.auth_update_profile.function_name
    invoke_arn    = aws_lambda_function.auth_update_profile.invoke_arn
  }
}

output "auth_change_password_function" {
  description = "Auth change password Lambda function"
  value = {
    arn           = aws_lambda_function.auth_change_password.arn
    function_name = aws_lambda_function.auth_change_password.function_name
    invoke_arn    = aws_lambda_function.auth_change_password.invoke_arn
  }
}