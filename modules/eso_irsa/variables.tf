variable "oidc_provider_url" {
  type        = string
  description = "URL del OICD provider del EKS"
}

variable "aws_region" {
  type        = string
  description = "Región de AWS"
}


variable "oidc_provider_arn" {
  type        = string
  description = "ARN del OICD provider del EKS"
}