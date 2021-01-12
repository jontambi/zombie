variable "name" {
  default     = "cka"
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC cidr block"
}

variable "private_subnets_cidr" {
  default     = ["10.0.2.0/24"]
  description = "A list of VPC private subnet IDs which the nodes are using."
}

variable "public_subnets_cidr" {
    description = "A list of VPC public subnet IDs which the nodes are using."
    default = ["10.0.0.0/24"]
}

variable "azs" {
  default     = ["us-east-1a"]
  description = "Available zones"
}

variable "prefix" {
  description = "This is the environment where your cluster is deployed. qa, prod, dev or demo"
}

variable "my_public_key" {
  default = "/home/john/Downloads/devops.pem"
}