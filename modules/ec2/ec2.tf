locals {
  ssh_user         = "centos"
  key_name         = "packer"
  private_key_path = "../../packer.pem"
  #private_key_path = "~/Downloads/devops.pem"
}

# Create AWS Instance

resource "aws_instance" "master_server" {
    count                       = 1

    ami                         = data.aws_ami.k8s_ami.id
    availability_zone           = element(var.azs, count.index)
    instance_type               = "t2.medium"
    key_name                    = local.key_name 
    vpc_security_group_ids      = [var.security_group]
    subnet_id                   = element(var.subnet_id, count.index)
    associate_public_ip_address = true 

    tags = {
        Name = "${var.environment}-${var.vpc_name}-cka-${count.index + 1}"
    }

    provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.master_server[count.index].public_ip
    }
  }
  provisioner "local-exec" {
    command = <<EOT
      sed -i 's/master_ip:/master_ip: ${aws_instance.master_server[count.index].public_ip}/' ../ansible/roles/k8s-master/vars/main.yaml;
      sed -i 's/end_point:/end_point: ${aws_instance.master_server[count.index].public_ip}/' ../ansible/roles/k8s-master/vars/main.yaml;
      ansible-playbook  -i ${aws_instance.master_server[count.index].public_ip}, --private-key ${local.private_key_path} ../ansible/k8s-master.yaml
    EOT
  }

}

# AWS Select latest AMI
data "aws_ami" "k8s_ami" {
    owners = ["179966331834"]
    most_recent = true

    filter {
        name = "state"
        values = ["available"]
    }

    filter {
        name = "tag:Name"
        values = ["Image_base_Centos7"]
    }
}