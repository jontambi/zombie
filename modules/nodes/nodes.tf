#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_launch_configuration" "node" {
  iam_instance_profile        = var.instance_profile
  image_id                    = local.ami_id
  instance_type               = var.instance_type
  name_prefix                 = "${var.environment}-${var.node_name}"
  key_name                    = var.key_pair
  associate_public_ip_address = true
  security_groups             = var.security_groups
  user_data_base64            = base64encode(local.user_data)
  spot_price                  = var.spot_price

  root_block_device {
    volume_size = var.disk_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node" {
  launch_configuration = aws_launch_configuration.node.id
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  name                 = "${var.environment}-${var.node_name}"
  vpc_zone_identifier  = var.subnet_id

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.node_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}