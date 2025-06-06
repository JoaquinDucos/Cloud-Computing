# Lambda function for listing all recipes
resource "aws_lambda_function" "list_recipes" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.project_name}-${var.environment}-list-recipes"
  role            = var.lambda_role_arn
  handler         = "recipes/list.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      RECIPES_TABLE = var.recipes_table
      IMAGES_BUCKET = var.images_bucket
    }
  }
}

# Lambda function for getting a single recipe
resource "aws_lambda_function" "get_recipe" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.project_name}-${var.environment}-get-recipe"
  role            = var.lambda_role_arn
  handler         = "recipes/get.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      RECIPES_TABLE = var.recipes_table
      IMAGES_BUCKET = var.images_bucket
    }
  }
}

# Lambda function for creating a new recipe
resource "aws_lambda_function" "create_recipe" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.project_name}-${var.environment}-create-recipe"
  role            = var.lambda_role_arn
  handler         = "recipes/create.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      RECIPES_TABLE = var.recipes_table
      IMAGES_BUCKET = var.images_bucket
    }
  }
}

# Lambda function for updating a recipe
resource "aws_lambda_function" "update_recipe" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.project_name}-${var.environment}-update-recipe"
  role            = var.lambda_role_arn
  handler         = "recipes/update.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      RECIPES_TABLE = var.recipes_table
      IMAGES_BUCKET = var.images_bucket
    }
  }
}

# Lambda function for deleting a recipe
resource "aws_lambda_function" "delete_recipe" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.project_name}-${var.environment}-delete-recipe"
  role            = var.lambda_role_arn
  handler         = "recipes/delete.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      RECIPES_TABLE = var.recipes_table
      IMAGES_BUCKET = var.images_bucket
    }
  }
}

# Lambda function for searching recipes
resource "aws_lambda_function" "search_recipes" {
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  function_name    = "${var.project_name}-${var.environment}-search-recipes"
  role            = var.lambda_role_arn
  handler         = "recipes/search.handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      RECIPES_TABLE = var.recipes_table
      IMAGES_BUCKET = var.images_bucket
    }
  }
}

# Lambda function for auth redirect
resource "aws_lambda_function" "auth_redirect" {
  filename         = "${path.module}/auth_redirect.zip"
  source_code_hash = filebase64sha256("${path.module}/auth_redirect.zip")
  function_name    = "${var.project_name}-${var.environment}-auth-redirect"
  role            = var.lambda_role_arn
  handler         = "auth_redirect_inline.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = 30

  environment {
    variables = {
      FRONTEND_URL = "http://${var.project_name}-${var.environment}-frontend.s3-website-us-east-1.amazonaws.com"
    }
  }
} 