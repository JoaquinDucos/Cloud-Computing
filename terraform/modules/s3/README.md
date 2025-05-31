# S3 Module

This module manages the S3 buckets for the recipe application.

## Resources Created

1. **Frontend Bucket**
   - Purpose: Hosts the static website files (HTML, CSS, JS)
   - Configuration:
     - Public access enabled
     - Website hosting enabled
     - Versioning enabled
     - Public read access via bucket policy
   - Example name: `cloud-computing-app-recetas-2025-dev-frontend`

2. **Images Bucket**
   - Purpose: Stores recipe images
   - Configuration:
     - Private access only
     - Versioning enabled
     - All public access blocked
   - Example name: `cloud-computing-app-recetas-2025-dev-images`

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Project name for resource naming | string | yes |
| environment | Environment (dev, staging, prod) | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| frontend_bucket_name | Name of the frontend S3 bucket |
| frontend_bucket_arn | ARN of the frontend S3 bucket |
| frontend_website_endpoint | Website endpoint for the frontend S3 bucket |
| images_bucket_name | Name of the images S3 bucket |
| images_bucket_arn | ARN of the images S3 bucket |

## Usage

```hcl
module "s3_buckets" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}
```

## Security Considerations

1. Frontend Bucket:
   - Public read access is required for website hosting
   - Only GET operations are allowed
   - Write operations are restricted

2. Images Bucket:
   - Completely private
   - Access only through Lambda functions
   - No public access allowed 