output "master_ip" {
    value = aws_instance.master_server[*].private_ip
}

output "worker_ip" {
    value = aws_instance.worker_server[*].private_ip
}