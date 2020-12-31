#terraform {
#  backend "s3" {}
#}

module "vpc" {
  source               = "../modules/vpc"
  vpc_name             = var.vpc_name
  environment          = var.prefix
  vpc_cidr             = var.vpc_cidr
  private_subnets_cidr = var.private_subnets_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  azs                  = var.azs
}

module "ec2" {
  source               = "../modules/ec2"
  vpc_name             = var.vpc_name
  environment          = var.prefix
#  private_subnets_cidr = var.private_subnets_cidr
  azs                  = var.azs
  subnet_id            = module.vpc.private_subnet_id
  my_public_key        = var.my_public_key
  security_group       = module.vpc.security_group

  depends_on = [ 
    module.rds
  ]
}

module "cluster" {
  source           = "../../modules/cluster"
  cluster_name     = var.cluster_name
  k8s_version      = var.k8s_version
  vpc_id           = module.vpc.vpc_id
  environment      = var.prefix
  subnet_id        = module.vpc.subnet_id
  workstation_cidr = [var.workstation_cidr]
  ssh_cidr         = var.ssh_cidr
  sg_name          = var.sg_name
  iam_name         = var.iam_name
  enable_kubectl   = var.enable_kubectl
  enable_dashboard = var.enable_dashboard
  enable_calico    = var.enable_calico
  enable_kube2iam  = var.enable_kube2iam
}

module "nodes" {
  source              = "../../modules/nodes"
  node_name           = var.node_name
  cluster_name        = module.cluster.name
  environment         = var.prefix
  cluster_endpoint    = module.cluster.endpoint
  cluster_certificate = module.cluster.certificate
  security_groups     = [module.cluster.node_security_group]
  instance_profile    = module.cluster.node_instance_profile
  subnet_id           = module.vpc.subnet_id
  ami_id              = var.node_ami_id
  ami_lookup          = var.node_ami_lookup
  instance_type       = var.node_instance_type
  user_data           = var.node_user_data
  bootstrap_arguments = var.node_bootstrap_arguments
  desired_capacity    = var.desired_capacity
  min_size            = var.node_min_size
  max_size            = var.node_max_size
  #key_pair            = var.key_pair
  key_pair            = module.cluster.ssh_key
  disk_size           = var.node_disk_size
}