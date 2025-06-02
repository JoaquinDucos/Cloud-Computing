resource "aws_dynamodb_table" "recipes" {
  name         = "${var.project_name}-${var.environment}-recipes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "title"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "TitleIndex"
    hash_key        = "title"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-recipes"
    Project     = var.project_name
    Environment = var.environment
  }
} 