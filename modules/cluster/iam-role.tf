#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services

# Cluster Role
resource "aws_iam_role" "cluster" {
  name                  = "EKSClusterRole-${var.environment}-${var.iam_name}"
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role.json
  permissions_boundary  = var.permissions_boundary
  force_detach_policies = true
}

data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

/*
 Adding a policy to cluster IAM role that allow permissions
 required to create AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
*/
data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cluster_elb_sl_role_creation" {
  name_prefix = "${var.environment}-${var.iam_name}-elb-sl-role-creation"
  role        = aws_iam_role.cluster.name
  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation.json
}

# Node Role
resource "aws_iam_role" "node" {
  name                  = "EKSNodeRole-${var.environment}-${var.iam_name}"
  assume_role_policy    = data.aws_iam_policy_document.node_assume_role.json
  permissions_boundary  = var.permissions_boundary
  force_detach_policies = true
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.environment}-${var.iam_name}"
  role = aws_iam_role.node.name
}

data "aws_iam_policy_document" "node_pv_role_creation" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "node_pv_role_creation" {
  name_prefix = "${var.environment}-${var.iam_name}-pv-role-creation"
  role        = aws_iam_role.node.name
  policy      = data.aws_iam_policy_document.node_pv_role_creation.json
}