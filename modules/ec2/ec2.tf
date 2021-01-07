# Create AWS Key Pair
resource "aws_key_pair" "ssh_default" {
    key_name = "ssh_wordpress"
    public_key = file(var.my_public_key)
}

# Create AWS Instance

resource "aws_instance" "cka_server" {
    count                       = 1

    ami                         = data.aws_ami.cka_ami.id
    availability_zone           = element(var.azs, count.index)
    instance_type               = "t2.micro"
    key_name                    = aws_key_pair.ssh_default.key_name
    vpc_security_group_ids      = [var.security_group]
    subnet_id                   = element(var.subnet_id, count.index)
    associate_public_ip_address = false

    tags = {
        Name = "${var.environment}-${var.vpc_name}-cka-${count.index + 1}"
    }
}


# AWS Select latest AMI
data "aws_ami" "cka_ami" {
    owners = ["179966331834"]
    most_recent = true

    filter {
        name = "state"
        values = ["available"]
    }

    filter {
        name = "tag:Name"
        values = ["cka_img"]
    }
}