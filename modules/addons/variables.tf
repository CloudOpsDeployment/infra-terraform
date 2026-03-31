variable "cluster_name" {
    type = string
    description = "this is the name of the cluster"
}

variable "oidc_provider_arn" {
    type = string
    description = "this is the ARN of the OIDC provider"
}

variable "oidc_provider_url" {
    type = string
    description = "this is the URL of the OIDC provider"
}