variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project - Will be used to construct names for all resources (S3, DynamoDB, Lambda)"
  type        = string
  default     = "cloud-computing-app-recetas-2025"  # This will create unique names like: cloud-computing-app-recetas-2025-dev-frontend
}

variable "environment" {
  description = "Environment name (dev, staging, prod) - Will be used in resource names"
  type        = string
  default     = "dev"  # This will be part of resource names: cloud-computing-app-recetas-2025-dev-*
}

# S3 Variables
variable "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend files"
  type        = string
  default     = "cloud-computing-app-recetas-2025-dev-frontend"
}

variable "images_bucket_name" {
  description = "Name of the S3 bucket for recipe images"
  type        = string
  default     = "cloud-computing-app-recetas-2025-dev-images"
}

# DynamoDB Variables
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "cloud-computing-app-recetas-2025-dev-recipes"
}

# Lambda Variables
variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.9"  # Yes, this is good as is for Python Lambda functions
} 