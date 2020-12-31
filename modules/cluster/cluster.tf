#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

# Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "${var.environment}-${var.sg_name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.sg_name}-cluster"
  }
}
resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  #cidr_blocks       = [local.workstation-external-cidr]
  count = length(flatten([var.workstation_cidr])) != 0 ? 1 : 0

  description       = "Allow workstation to communicate with the cluster API Server"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = flatten([var.workstation_cidr])
}
# Node Security Group
resource "aws_security_group" "node" {
  name        = "${var.environment}-${var.sg_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                 = "${var.environment}-${var.sg_name}-node"
    "kubernetes.io/cluster/${var.environment}-${var.sg_name}" = "owned"
  }
}

resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_allow_ssh" {
  count = length(var.ssh_cidr) != 0 ? 1 : 0

  description       = "The CIDR blocks from which to allow incoming ssh connections to the EKS nodes"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.node.id
  cidr_blocks       = [var.ssh_cidr]
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_ingress_cluster_https" {
  description              = "Allow incoming https connections from the EKS masters security group"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_eks_cluster" "cluster" {
  name     = "${var.environment}-${var.cluster_name}"
  version  = var.k8s_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    #subnet_ids              = var.subnet_id
    subnet_ids              = flatten([var.subnet_id])
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.cluster_private_access
    endpoint_public_access  = var.cluster_public_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
  ]
}

resource "aws_key_pair" "ssh" {
  key_name   = "ssh-deployer-key-dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeqUU53DoUUnNch4Bpf/hdz/dHPUAK0OH9cReESk8KZKXoAROsUP7PzW+/9uNjNBpIek26uH0WVS9r0yBn07orsPpu5eabmozTOMyPK6tzsIgFDxus6YrrvJ+K0WHw1SJra3tjMfnccb4CqEM630ktZNUnHriSP3g/nzu6L0q84UDBmj8yma6rpmx3uK9E9MgLA3coM3MHdT9HTa4f6bG8NJNZGdrpQoTIHBELa2OxfYUbl2L0mpcGn/gsKIQggF3DobY26O4v9jrNrmoMRsFvcncKCEcA6vcBUcDMe8AhBZcP+szXnV5ld34buoGsRp1/RUf1Jcz/64Xr3hx/rXqj ouroboros@DESKTOP-KFUOONJ"
}
