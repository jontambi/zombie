#output "cka_ip" {
#  value = module.ec2.cka_ip
#}

output "master_ip" {
    value = module.ec2.master_ip
}

output "woker_ip" {
    value = module.ec2.worker_ip
}

#output "eip_nat" {
#    value = module.vpc.aws_eip
#}