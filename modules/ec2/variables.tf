variable "environment" {
  description = "This is the environment where your cluster is deployed. qa, prod, or dev"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "azs" {
  description = "Available zones"
}

variable "subnet_id" {
  description = "VPC Private Subnets ID"
}

variable "my_public_key" {
  
}

variable "security_group" {
  
}