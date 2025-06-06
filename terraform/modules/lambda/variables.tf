variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package"
  type        = string
  default     = "lambda.zip"
}

variable "recipes_table" {
  description = "Name of the DynamoDB recipes table"
  type        = string
}

variable "images_bucket" {
  description = "Name of the S3 bucket for images"
  type        = string
} 