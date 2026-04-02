variable "cluster_name" {
  type        = string
  description = "this is the name of the cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "this is the ARN of the OIDC provider"
}

variable "oidc_provider_url" {
  type        = string
  description = "this is the URL of the OIDC provider"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "enable_gateway_api" {
  type        = bool
  description = "Enable Gateway API Helm release installation"
  default     = true
}
