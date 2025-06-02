output "dynamodb" {
    description = "Information about DynamoDB table"
  value = {
    table_name = module.dynamodb.table_name
    table_arn  = module.dynamodb.table_arn
  }
}

output "s3_buckets" {
  description = "Information about S3 buckets"
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

output "cognito" {
  description = "Information about Cognito User Pool"
  value = {
    user_pool_id        = module.cognito.user_pool_id
    user_pool_client_id = module.cognito.user_pool_client_id
    user_pool_domain    = module.cognito.user_pool_domain
    user_pool_endpoint  = module.cognito.user_pool_endpoint
  }
}

output "lambda_functions" {
  description = "Information about Lambda functions"
  value = {
    functions = {
      list_recipes     = module.lambda.list_recipes_lambda_name
      get_recipe       = module.lambda.get_recipe_lambda_name
      create_recipe    = module.lambda.create_recipe_lambda_name
      update_recipe    = module.lambda.update_recipe_lambda_name
      delete_recipe    = module.lambda.delete_recipe_lambda_name
      search_recipes   = module.lambda.search_recipes_lambda_name
      auth_redirect    = module.lambda.auth_redirect_lambda_name
    }
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  }
}

output "api_gateway" {
  description = "Information about API Gateway"
  value = {
    endpoint  = module.apigateway.api_endpoint
    stage_url = module.apigateway.stage_url
  }
} 