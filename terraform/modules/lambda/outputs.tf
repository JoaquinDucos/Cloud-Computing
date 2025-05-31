output "list_recipes_function_name" {
  description = "Name of the list recipes Lambda function"
  value       = aws_lambda_function.list_recipes.function_name
}

output "list_recipes_function_arn" {
  description = "ARN of the list recipes Lambda function"
  value       = aws_lambda_function.list_recipes.arn
}

output "get_recipe_function_name" {
  description = "Name of the get recipe Lambda function"
  value       = aws_lambda_function.get_recipe.function_name
}

output "get_recipe_function_arn" {
  description = "ARN of the get recipe Lambda function"
  value       = aws_lambda_function.get_recipe.arn
}

output "create_recipe_function_name" {
  description = "Name of the create recipe Lambda function"
  value       = aws_lambda_function.create_recipe.function_name
}

output "create_recipe_function_arn" {
  description = "ARN of the create recipe Lambda function"
  value       = aws_lambda_function.create_recipe.arn
}

output "update_recipe_function_name" {
  description = "Name of the update recipe Lambda function"
  value       = aws_lambda_function.update_recipe.function_name
}

output "update_recipe_function_arn" {
  description = "ARN of the update recipe Lambda function"
  value       = aws_lambda_function.update_recipe.arn
}

output "delete_recipe_function_name" {
  description = "Name of the delete recipe Lambda function"
  value       = aws_lambda_function.delete_recipe.function_name
}

output "delete_recipe_function_arn" {
  description = "ARN of the delete recipe Lambda function"
  value       = aws_lambda_function.delete_recipe.arn
}

output "search_recipes_function_name" {
  description = "Name of the search recipes Lambda function"
  value       = aws_lambda_function.search_recipes.function_name
}

output "search_recipes_function_arn" {
  description = "ARN of the search recipes Lambda function"
  value       = aws_lambda_function.search_recipes.arn
} 