variable "node_instance_type" {
    description = "EC2 instance type for EKS worker nodes"
    type        = string
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