# S3 Buckets
module "s3_buckets" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# DynamoDB Table
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

# Cognito Module
module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  environment  = var.environment
  frontend_url = module.apigateway.stage_url
}

# Lambda Functions
module "lambda" {
  source = "./modules/lambda"

  project_name     = var.project_name
  environment      = var.environment
  lambda_runtime   = var.lambda_runtime
  recipes_table    = module.dynamodb.table_name
  images_bucket    = module.s3_buckets.images_bucket_name
  lambda_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

# API Gateway
module "apigateway" {
  source = "./modules/apigateway"

  project_name     = var.project_name
  environment      = var.environment
  aws_region       = var.aws_region

  # Cognito configuration
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id

  # Lambda function ARNs
  list_recipes_lambda_arn     = module.lambda.list_recipes_lambda_arn
  get_recipe_lambda_arn       = module.lambda.get_recipe_lambda_arn
  create_recipe_lambda_arn    = module.lambda.create_recipe_lambda_arn
  update_recipe_lambda_arn    = module.lambda.update_recipe_lambda_arn
  delete_recipe_lambda_arn    = module.lambda.delete_recipe_lambda_arn
  search_recipes_lambda_arn   = module.lambda.search_recipes_lambda_arn
  auth_redirect_lambda_arn    = module.lambda.auth_redirect_lambda_arn

  # Lambda function names
  list_recipes_lambda_name     = module.lambda.list_recipes_lambda_name
  get_recipe_lambda_name       = module.lambda.get_recipe_lambda_name
  create_recipe_lambda_name    = module.lambda.create_recipe_lambda_name
  update_recipe_lambda_name    = module.lambda.update_recipe_lambda_name
  delete_recipe_lambda_name    = module.lambda.delete_recipe_lambda_name
  search_recipes_lambda_name   = module.lambda.search_recipes_lambda_name
  auth_redirect_lambda_name    = module.lambda.auth_redirect_lambda_name

  depends_on = [
    module.lambda
  ]
}

# Generate config.js from template
resource "local_file" "config_js" {
  content = templatefile("${path.root}/../config.js.tpl", {
    api_gateway_url     = module.apigateway.stage_url
    user_pool_id        = module.cognito.user_pool_id
    user_pool_client_id = module.cognito.user_pool_client_id
    user_pool_domain    = module.cognito.user_pool_domain
    aws_region          = var.aws_region
  })
  filename = "${path.root}/../config.js"
}

# Generate auth.js from template (simplified)
resource "local_file" "auth_js" {
  content = templatefile("${path.root}/../auth.js.tpl", {})
  filename = "${path.root}/../auth.js"
}

# Upload generated files to S3
resource "aws_s3_object" "config_js" {
  bucket       = module.s3_buckets.frontend_bucket_name
  key          = "config.js"
  source       = local_file.config_js.filename
  content_type = "application/javascript"
  etag         = local_file.config_js.content_md5

  depends_on = [local_file.config_js]
}

resource "aws_s3_object" "auth_js" {
  bucket       = module.s3_buckets.frontend_bucket_name
  key          = "auth.js"
  source       = local_file.auth_js.filename
  content_type = "application/javascript"
  etag         = local_file.auth_js.content_md5

  depends_on = [local_file.auth_js]
}

resource "aws_s3_object" "home_html" {
  bucket       = module.s3_buckets.frontend_bucket_name
  key          = "home.html"
  source       = "${path.root}/../home.html"
  content_type = "text/html"
  etag         = filemd5("${path.root}/../home.html")
}

resource "aws_s3_object" "index_html" {
  bucket       = module.s3_buckets.frontend_bucket_name
  key          = "index.html"
  source       = "${path.root}/../index.html"
  content_type = "text/html"
  etag         = filemd5("${path.root}/../index.html")
}

resource "aws_s3_object" "receta_html" {
  bucket       = module.s3_buckets.frontend_bucket_name
  key          = "receta.html"
  source       = "${path.root}/../receta.html"
  content_type = "text/html"
  etag         = filemd5("${path.root}/../receta.html")
}

# Data sources
data "aws_caller_identity" "current" {} 