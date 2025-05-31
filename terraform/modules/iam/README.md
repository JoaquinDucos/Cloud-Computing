# IAM Module

This module manages the IAM roles and policies for Lambda functions.

## Resources Created

1. **Lambda Execution Role**
   - Name: `{project_name}-{environment}-lambda-role`
   - Purpose: Main execution role for all Lambda functions
   - Trusted Entity: Lambda service

2. **DynamoDB Access Policy**
   - Name: `{project_name}-{environment}-dynamodb-policy`
   - Purpose: Allows Lambda functions to interact with DynamoDB
   - Actions:
     - GetItem
     - PutItem
     - UpdateItem
     - DeleteItem
     - Query
     - Scan

3. **S3 Access Policy**
   - Name: `{project_name}-{environment}-s3-policy`
   - Purpose: Allows Lambda functions to interact with S3 images bucket
   - Actions:
     - GetObject
     - PutObject
     - DeleteObject
     - ListBucket

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Project name for resource naming | string | yes |
| environment | Environment (dev, staging, prod) | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda_role_arn | ARN of the Lambda execution role |
| lambda_role_name | Name of the Lambda execution role |

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}
```

## Security Considerations

1. **Principle of Least Privilege**
   - Roles and policies follow minimal required permissions
   - Resources are explicitly defined using project naming convention
   - No wildcard permissions except where necessary (DynamoDB indexes)

2. **Resource Access**
   - DynamoDB: Limited to specific table and its indexes
   - S3: Limited to specific images bucket
   - No unnecessary permissions included

3. **Policy Structure**
   - Policies are attached directly to role
   - Clear separation between DynamoDB and S3 permissions
   - Resource ARNs are constructed using project variables 