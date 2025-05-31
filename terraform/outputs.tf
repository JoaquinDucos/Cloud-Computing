output "dynamodb" {
  description = "DynamoDB table details"
  value = {
    table_name = module.dynamodb.table_name
    table_arn  = module.dynamodb.table_arn
  }
}

output "s3_buckets" {
  description = "S3 bucket details"
  value = {
    frontend = {
      name             = module.s3_buckets.frontend_bucket_name
      website_endpoint = module.s3_buckets.frontend_website_endpoint
    }
    images = {
      name = module.s3_buckets.images_bucket_name
    }
  }
}

output "lambda_functions" {
  description = "Lambda function details"
  value = {
    functions = {
      list_recipes   = module.lambda.list_recipes_function_name
      get_recipe     = module.lambda.get_recipe_function_name
      create_recipe  = module.lambda.create_recipe_function_name
      update_recipe  = module.lambda.update_recipe_function_name
      delete_recipe  = module.lambda.delete_recipe_function_name
      search_recipes = module.lambda.search_recipes_function_name
    }
    role_arn = "arn:aws:iam::923413929409:role/LabRole"  # Using the AWS Academy default role
  }
}

output "api_gateway" {
  description = "API Gateway details"
  value = {
    endpoint  = module.apigateway.api_endpoint
    stage_url = module.apigateway.stage_url
  }
} 