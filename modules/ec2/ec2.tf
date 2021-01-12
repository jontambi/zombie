locals {
  ssh_user         = "ubuntu"
  key_name         = "packer"
  private_key_path = "../../packer.pem"
  #private_key_path = "~/Downloads/devops.pem"
}

# Create AWS Instance

resource "aws_instance" "cka_server" {
    count                       = 1

    ami                         = data.aws_ami.cka_ami.id
    availability_zone           = element(var.azs, count.index)
    instance_type               = "t2.medium"
    key_name                    = local.key_name 
    vpc_security_group_ids      = [var.security_group]
    subnet_id                   = element(var.subnet_id, count.index)
    associate_public_ip_address = true 

    tags = {
        Name = "${var.environment}-${var.vpc_name}-cka-${count.index + 1}"
    }
/***
    provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cka_server[count.index].public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.cka_server[count.index].public_ip}, --private-key ${local.private_key_path} ../ansible/k8s-requirements.yaml"
  }
***/
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
        values = ["Image_base_Ubuntu1804"]
    }
}