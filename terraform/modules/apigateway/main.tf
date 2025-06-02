resource "aws_apigatewayv2_api" "recipes_api" {
  name          = "${var.project_name}-${var.environment}-recipes-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "recipes_stage" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  name   = var.environment
  auto_deploy = true
}

# Cognito Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id           = aws_apigatewayv2_api.recipes_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.project_name}-${var.environment}-cognito-authorizer"

  jwt_configuration {
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

# List recipes integration
resource "aws_apigatewayv2_integration" "list_recipes" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.list_recipes_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_recipes" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "GET /recipes"
  target    = "integrations/${aws_apigatewayv2_integration.list_recipes.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Get recipe integration
resource "aws_apigatewayv2_integration" "get_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.get_recipe_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "GET /recipes/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_recipe.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Create recipe integration
resource "aws_apigatewayv2_integration" "create_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.create_recipe_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "POST /recipes"
  target    = "integrations/${aws_apigatewayv2_integration.create_recipe.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Update recipe integration
resource "aws_apigatewayv2_integration" "update_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.update_recipe_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "PUT /recipes/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_recipe.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Delete recipe integration
resource "aws_apigatewayv2_integration" "delete_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.delete_recipe_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_recipe" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "DELETE /recipes/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_recipe.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Search recipes integration
resource "aws_apigatewayv2_integration" "search_recipes" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.search_recipes_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "search_recipes" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "GET /recipes/search"
  target    = "integrations/${aws_apigatewayv2_integration.search_recipes.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Auth redirect integration
resource "aws_apigatewayv2_integration" "auth_redirect" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.auth_redirect_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_callback" {
  api_id = aws_apigatewayv2_api.recipes_api.id
  route_key = "GET /auth/callback"
  target    = "integrations/${aws_apigatewayv2_integration.auth_redirect.id}"
}

# Auth logout route (public)
resource "aws_apigatewayv2_route" "auth_logout" {
  api_id    = aws_apigatewayv2_api.recipes_api.id
  route_key = "GET /auth/logout"
  target    = "integrations/${aws_apigatewayv2_integration.auth_redirect.id}"
}

# Lambda permissions
resource "aws_lambda_permission" "list_recipes" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.list_recipes_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_recipe" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.get_recipe_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "create_recipe" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.create_recipe_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_recipe" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.update_recipe_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete_recipe" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.delete_recipe_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "search_recipes" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.search_recipes_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "auth_redirect" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_redirect_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.recipes_api.execution_arn}/*/*"
} 