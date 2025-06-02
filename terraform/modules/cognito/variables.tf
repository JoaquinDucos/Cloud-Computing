variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "frontend_url" {
  description = "Frontend URL for Cognito callbacks"
  type        = string
} 