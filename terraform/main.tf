# S3 Buckets
module "s3_buckets" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# DynamoDB Table
module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = "${var.project_name}-${var.environment}-recipes"
}
## WE DON'T HAVE IAM ROLE PERMISSIONS BECAUSE OF THE Lab AWS Academy 
# Lambda Functions
module "lambda" {
  source = "./modules/lambda"

  project_name        = var.project_name
  environment         = var.environment
  lambda_runtime      = var.lambda_runtime
  lambda_role_arn     = "arn:aws:iam::923413929409:role/LabRole"  # Using the AWS Academy default role
  lambda_zip_path     = "${path.module}/lambda.zip"
  dynamodb_table_name = module.dynamodb.table_name
  images_bucket_name  = module.s3_buckets.images_bucket_name
  
  depends_on = [
    module.dynamodb,
    module.s3_buckets
  ]
}

# API Gateway
module "apigateway" {
  source = "./modules/apigateway"

  project_name = var.project_name
  environment  = var.environment

  list_recipes_lambda_arn   = module.lambda.list_recipes_function_arn
  get_recipe_lambda_arn     = module.lambda.get_recipe_function_arn
  create_recipe_lambda_arn  = module.lambda.create_recipe_function_arn
  update_recipe_lambda_arn  = module.lambda.update_recipe_function_arn
  delete_recipe_lambda_arn  = module.lambda.delete_recipe_function_arn
  search_recipes_lambda_arn = module.lambda.search_recipes_function_arn

  list_recipes_lambda_name   = module.lambda.list_recipes_function_name
  get_recipe_lambda_name     = module.lambda.get_recipe_function_name
  create_recipe_lambda_name  = module.lambda.create_recipe_function_name
  update_recipe_lambda_name  = module.lambda.update_recipe_function_name
  delete_recipe_lambda_name  = module.lambda.delete_recipe_function_name
  search_recipes_lambda_name = module.lambda.search_recipes_function_name

  depends_on = [
    module.lambda
  ]
} 