variable "node_instance_type" {
    description = "EC2 instance type for EKS worker nodes"
    type        = string
    default     = "t3.small"
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs for the EKS cluster"
    type        = list(string)
}