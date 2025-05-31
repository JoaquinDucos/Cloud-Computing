variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "frontend_bucket_name" {
  description = "Optional name of the S3 bucket for frontend files. If not provided, will be constructed from project_name and environment."
  type        = string
  default     = ""
}

variable "images_bucket_name" {
  description = "Optional name of the S3 bucket for recipe images. If not provided, will be constructed from project_name and environment."
  type        = string
  default     = ""
} 