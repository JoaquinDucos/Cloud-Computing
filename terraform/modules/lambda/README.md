# Lambda Module

This module manages the Lambda functions for the recipe application API.

## Functions Created

1. **List Recipes** (`list-recipes`)
   - Purpose: Get all recipes
   - Handler: `recipes/list.handler`
   - Example name: `cloud-computing-app-recetas-2025-dev-list-recipes`

2. **Get Recipe** (`get-recipe`)
   - Purpose: Get a single recipe by ID
   - Handler: `recipes/get.handler`
   - Example name: `cloud-computing-app-recetas-2025-dev-get-recipe`

3. **Create Recipe** (`create-recipe`)
   - Purpose: Create a new recipe
   - Handler: `recipes/create.handler`
   - Example name: `cloud-computing-app-recetas-2025-dev-create-recipe`

4. **Update Recipe** (`update-recipe`)
   - Purpose: Update an existing recipe
   - Handler: `recipes/update.handler`
   - Example name: `cloud-computing-app-recetas-2025-dev-update-recipe`

5. **Delete Recipe** (`delete-recipe`)
   - Purpose: Delete a recipe
   - Handler: `recipes/delete.handler`
   - Example name: `cloud-computing-app-recetas-2025-dev-delete-recipe`

6. **Search Recipes** (`search-recipes`)
   - Purpose: Search recipes by title
   - Handler: `recipes/search.handler`
   - Example name: `cloud-computing-app-recetas-2025-dev-search-recipes`

## Common Configuration

All functions share:
- Runtime: Python 3.9
- Timeout: 30 seconds
- Memory: Default (128MB)
- Environment Variables:
  - RECIPES_TABLE: DynamoDB table name
  - IMAGES_BUCKET: S3 bucket name

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Project name for resource naming | string | yes |
| environment | Environment (dev, staging, prod) | string | yes |
| lambda_runtime | Runtime for Lambda functions | string | yes |
| lambda_role_arn | ARN of the Lambda execution role | string | yes |
| lambda_zip_path | Path to the Lambda deployment package | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| list_recipes_function_name | Name of the list recipes function |
| get_recipe_function_name | Name of the get recipe function |
| create_recipe_function_name | Name of the create recipe function |
| update_recipe_function_name | Name of the update recipe function |
| delete_recipe_function_name | Name of the delete recipe function |
| search_recipes_function_name | Name of the search recipes function |

## Usage

```hcl
module "lambda" {
  source = "./modules/lambda"

  project_name    = var.project_name
  environment     = var.environment
  lambda_runtime  = var.lambda_runtime
  lambda_role_arn = module.iam.lambda_role_arn
  lambda_zip_path = "${path.module}/lambda.zip"
}
```

## Function Code Structure

The Lambda code should be organized in the `src/lambda/recipes/` directory:
```
src/lambda/recipes/
├── list.py
├── get.py
├── create.py
├── update.py
├── delete.py
└── search.py
```

## Deployment Package

The Lambda code needs to be zipped before applying Terraform:
```bash
cd src/lambda
zip -r ../../terraform/lambda.zip ./*
``` 