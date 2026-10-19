variable "trusted_principals" {
  description = "ARNs of users, roles, or CI/CD identities allowed to assume the Terraform role"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  type        = string
  description = "region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Dev environment"
  type        = string
  default     = "dev"
}