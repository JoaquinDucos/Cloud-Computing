variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev, prod, etc.)"
  type        = string
}

variable "list_recipes_lambda_arn" {
  description = "The ARN of the list recipes Lambda function"
  type        = string
}

variable "get_recipe_lambda_arn" {
  description = "The ARN of the get recipe Lambda function"
  type        = string
}

variable "create_recipe_lambda_arn" {
  description = "The ARN of the create recipe Lambda function"
  type        = string
}

variable "update_recipe_lambda_arn" {
  description = "The ARN of the update recipe Lambda function"
  type        = string
}

variable "delete_recipe_lambda_arn" {
  description = "The ARN of the delete recipe Lambda function"
  type        = string
}

variable "search_recipes_lambda_arn" {
  description = "The ARN of the search recipes Lambda function"
  type        = string
}

variable "list_recipes_lambda_name" {
  description = "The name of the list recipes Lambda function"
  type        = string
}

variable "get_recipe_lambda_name" {
  description = "The name of the get recipe Lambda function"
  type        = string
}

variable "create_recipe_lambda_name" {
  description = "The name of the create recipe Lambda function"
  type        = string
}

variable "update_recipe_lambda_name" {
  description = "The name of the update recipe Lambda function"
  type        = string
}

variable "delete_recipe_lambda_name" {
  description = "The name of the delete recipe Lambda function"
  type        = string
}

variable "search_recipes_lambda_name" {
  description = "The name of the search recipes Lambda function"
  type        = string
} 