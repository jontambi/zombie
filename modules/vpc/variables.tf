variable "environment" {
  description = "This is the environment where your cluster is deployed. qa, prod, or dev"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr block"
}

variable "private_subnets_cidr" {
  description = "VPC Private Subnets"
}

variable "public_subnets_cidr" {
  description = "VPC Public Subnets"
}

variable "azs" {
  description = "Available zones"
}