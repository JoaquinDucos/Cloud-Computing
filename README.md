# Recipe Application Infrastructure

This project contains the infrastructure as code (IaC) for a serverless recipe application using AWS services.

## Architecture Overview

![Architecture](recetas.png)

The application uses the following AWS services:
- **S3 Buckets**:
  - Frontend bucket (public) for hosting the web application
  - Images bucket (private) for storing recipe images
- **DynamoDB**: For storing recipe data
- **Lambda Functions**: For serverless API endpoints
- **API Gateway**: For RESTful API management

## Features

- Create, read, update, and delete recipes
- Search recipes by title, category, or ingredients
- Responsive web interface
- Serverless architecture
- Infrastructure as Code with Terraform

## Data Model

### Recipe
```typescript
interface Recipe {
    id: string;
    userId: string;
    title: string;
    description: string;
    time: number;         // Time in minutes
    category: string;     // e.g., "desayuno", "almuerzo", "cena", etc.
    ingredients: string[];
    instructions: string[];
    imageUrl: string | null;
    createdAt: string;
    updatedAt: string;
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /recipes | List all recipes |
| GET | /recipes/{id} | Get a specific recipe |
| POST | /recipes | Create a new recipe |
| PUT | /recipes/{id} | Update a recipe |
| DELETE | /recipes/{id} | Delete a recipe |
| GET | /recipes/search | Search recipes by title, category, or ingredients |

## Project Structure

```
.
├── terraform/
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Variable definitions
│   ├── terraform.tfvars  # Variable values
│   ├── outputs.tf        # Output definitions
│   ├── providers.tf      # AWS provider configuration
│   └── modules/
│       ├── s3/          # S3 buckets configuration
│       ├── dynamodb/    # DynamoDB table configuration
│       ├── apigateway/  # API Gateway configuration
│       └── lambda/      # Lambda functions configuration
├── src/
│   └── lambda/
│       └── recipes/     # Lambda function code
└── *.html              # Frontend static files
```

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (version >= 1.2.0)
3. AWS credentials with appropriate permissions
4. Python 3.9 or higher

## Configuration

The infrastructure is configured using variables in `terraform.tfvars`:

```hcl
aws_region     = "us-east-1"
project_name   = "cloud-computing-app-recetas-2025"
environment    = "dev"
lambda_runtime = "python3.9"
```

This creates resources with names following the pattern:
- `{project_name}-{environment}-{resource}`
Example: `cloud-computing-app-recetas-2025-dev-frontend`

## Resource Naming

All resources follow a consistent naming convention:
- S3 Frontend: `{project_name}-{environment}-frontend`
- S3 Images: `{project_name}-{environment}-images`
- DynamoDB: `{project_name}-{environment}-recipes`
- Lambda Functions: `{project_name}-{environment}-{function-name}`
- API Gateway: `{project_name}-{environment}-recipes-api`

## Deployment

1. Initialize Terraform:
```bash
cd terraform
terraform init
```

2. Review changes:
```bash
terraform plan
```

3. Apply changes:
```bash
terraform apply
```

4. Upload frontend files:
```bash
aws s3 cp ../home.html s3://{frontend-bucket}/home.html --content-type "text/html"
aws s3 cp ../index.html s3://{frontend-bucket}/index.html --content-type "text/html"
aws s3 cp ../receta.html s3://{frontend-bucket}/receta.html --content-type "text/html"
```

5. To destroy infrastructure:
```bash
terraform destroy
```

## Security Considerations

- Frontend bucket is public (required for website hosting)
- Images bucket is private (accessed via signed URLs)
- Lambda functions have minimal required permissions through LabRole
- CORS is properly configured in API Gateway
- All resources are tagged for better organization

## Local Development

1. Create a Python virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install boto3
```

## Known Limitations

- Using AWS Academy LabRole, so custom IAM roles cannot be created
- Image upload functionality is prepared but not implemented in this version
- Authentication is not implemented in this version

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Modules Documentation

See individual README files in each module directory for detailed documentation:
- [S3 Module](terraform/modules/s3/README.md)
- [DynamoDB Module](terraform/modules/dynamodb/README.md)
- [API Gateway Module](terraform/modules/apigateway/README.md)
- [Lambda Module](terraform/modules/lambda/README.md)
