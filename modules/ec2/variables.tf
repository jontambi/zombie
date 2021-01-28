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

variable "public_subnet_id" {
  description = "VPC Public Subnets ID"
}

#variable "private_subnet_id" {
#  description = "VPC Private Subnets ID"
#}

variable "my_public_key" {
  
}

#variable "security_group" {
#  
#}

variable "master_security_group" {
  
}

#variable "worker_security_group" {
#  
#}

#variable "aws_eip" {
#  
#}