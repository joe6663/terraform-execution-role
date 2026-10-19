output "terraform_execution_role_arn" {
  description = "Pass this ARN into the provider 'aws' assume_role block"
  value       = aws_iam_role.terraform_execution.arn
}