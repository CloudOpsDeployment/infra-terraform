variable "project_name" {
  description = "Base name used as prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}