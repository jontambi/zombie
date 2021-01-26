#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#
resource "aws_vpc" "vpc" {
  #name                 = "${var.environment}-${var.vpc_name}"
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = map(
    "Name", "${var.environment}-${var.vpc_name}-vpc",
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-${var.vpc_name}-internetgateway"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets_cidr)

  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id

  tags = map(
    "Name", "${var.environment}-${var.vpc_name}-private-subnet-${count.index + 1}",
  )
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets_cidr)
  map_public_ip_on_launch = true

  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.public_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id

  tags = map(
    "Name", "${var.environment}-${var.vpc_name}-public-subnet-${count.index + 1}",
  )

}

resource "aws_default_route_table" "route_private" {
  #count = length(var.private_subnets_cidr)
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.environment}-${var.vpc_name}-privateRouteTable" 
  }
}

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-${var.vpc_name}-publicRouteTable"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)

  route_table_id = aws_default_route_table.route_private.id
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)

  route_table_id = aws_route_table.route_public.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)  
}

resource "aws_eip" "nat" {
  vpc   = true
  
  tags = {
    Name = "${var.environment}-${var.vpc_name}-ElasticIP"
  }
}
/***
resource "aws_nat_gateway" "default" {
  depends_on = [ 
    aws_internet_gateway.igw
  ]

  #count         = length(var.public_subnets_cidr)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.0.id

  tags = {
    Name = "${var.environment}-${var.vpc_name}-NAT"
  }
  
}
***/
# Security Group Creation
resource "aws_security_group" "master_sg" {
  name   = "master-sg"
  vpc_id = aws_vpc.vpc.id
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.master_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "api_inbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.master_sg.id
  to_port           =0
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "etcd_kubeapi_inbound_access" {
  from_port         = 2379
  protocol          = "tcp"
  security_group_id = aws_security_group.master_sg.id
  to_port           = 2380
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "kubelet_inbound_access" {
  from_port         = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.master_sg.id
  to_port           = 10250
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "scheduler_inbound_access" {
  from_port         = 10251
  protocol          = "tcp"
  security_group_id = aws_security_group.master_sg.id
  to_port           = 10251
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "cmanager_inbound_access" {
  from_port         = 10252
  protocol          = "tcp"
  security_group_id = aws_security_group.master_sg.id
  to_port           = 10252
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.master_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "worker_sg" {
  name = "worker-sg"
  vpc_id = aws_vpc.vpc.id
}

# All InBound Access Worker
resource "aws_security_group_rule" "k8s_all_inbound_access" {
  from_port         = 0 
  protocol          = "-1"
  security_group_id = aws_security_group.worker_sg.id
  to_port           = 0
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access Worker
resource "aws_security_group_rule" "k8s_all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.worker_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = [var.vpc_cidr]
}