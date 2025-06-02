variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# Cognito variables
variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  type        = string
}

# Lambda function ARNs
variable "list_recipes_lambda_arn" {
  description = "ARN of the list recipes Lambda function"
  type        = string
}

variable "get_recipe_lambda_arn" {
  description = "ARN of the get recipe Lambda function"
  type        = string
}

variable "create_recipe_lambda_arn" {
  description = "ARN of the create recipe Lambda function"
  type        = string
}

variable "update_recipe_lambda_arn" {
  description = "ARN of the update recipe Lambda function"
  type        = string
}

variable "delete_recipe_lambda_arn" {
  description = "ARN of the delete recipe Lambda function"
  type        = string
}

variable "search_recipes_lambda_arn" {
  description = "ARN of the search recipes Lambda function"
  type        = string
}

variable "auth_redirect_lambda_arn" {
  description = "ARN of the auth redirect Lambda function"
  type        = string
}

# Lambda function names
variable "list_recipes_lambda_name" {
  description = "Name of the list recipes Lambda function"
  type        = string
}

variable "get_recipe_lambda_name" {
  description = "Name of the get recipe Lambda function"
  type        = string
}

variable "create_recipe_lambda_name" {
  description = "Name of the create recipe Lambda function"
  type        = string
}

variable "update_recipe_lambda_name" {
  description = "Name of the update recipe Lambda function"
  type        = string
}

variable "delete_recipe_lambda_name" {
  description = "Name of the delete recipe Lambda function"
  type        = string
}

variable "search_recipes_lambda_name" {
  description = "Name of the search recipes Lambda function"
  type        = string
}

variable "auth_redirect_lambda_name" {
  description = "Name of the auth redirect Lambda function"
  type        = string
} 