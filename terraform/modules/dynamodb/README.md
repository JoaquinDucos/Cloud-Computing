# DynamoDB Module

This module manages the DynamoDB table for storing recipe data.

## Table Configuration

- **Table Name**: `{project_name}-{environment}-recipes`
- **Billing Mode**: PAY_PER_REQUEST (on-demand)
- **Primary Key**: 
  - Partition Key: `id` (String)

## Global Secondary Indexes (GSIs)

1. **UserIdIndex**
   - Purpose: Query recipes by user
   - Partition Key: `userId` (String)
   - Projection: ALL

2. **TitleIndex**
   - Purpose: Search recipes by title
   - Partition Key: `title` (String)
   - Projection: ALL

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| table_name | Name of the DynamoDB table | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| table_name | Name of the DynamoDB table |
| table_arn | ARN of the DynamoDB table |

## Usage

```hcl
module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = "${var.project_name}-${var.environment}-recipes"
}
```

## Table Schema

The table is designed to store recipe data with the following attributes:
- `id`: Unique identifier for the recipe (String, Primary Key)
- `userId`: ID of the user who created the recipe (String, GSI)
- `title`: Title of the recipe (String, GSI)
- Additional fields handled by the application:
  - description
  - ingredients
  - instructions
  - imageUrl
  - createdAt
  - updatedAt

## Access Patterns

The table design supports the following access patterns:
1. Get recipe by ID (Primary Key)
2. Get all recipes by user (UserIdIndex)
3. Search recipes by title (TitleIndex)
4. Full table scan (for listing all recipes)

## Security

- Access is restricted to Lambda functions via IAM roles
- No direct public access
- On-demand capacity prevents throttling 