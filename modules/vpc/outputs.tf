output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

#output "public_subnet1" {
#  value = element(aws_subnet.nat_gateway.*.id, 1 )
#}

#output "public_subnet2" {
#  value = element(aws_subnet.nat_gateway.*.id, 2 )
#}

/***
output "public_route_table_id" {
  value = aws_route_table.route_public[*].id
}

output "private_route_table_id" {
  value = aws_default_route_table.route_private[*].id
}

output "private_subnet1" {
  value = element(aws_subnet.private_subnet.*.id, 3 )
}

output "private_subnet2" {
  value = element(aws_subnet.private_subnet.*.id, 4 )
}
***/

output "master_security_group" {
  value = aws_security_group.master_sg.id
}

#output "worker_security_group" {
#  value = aws_security_group.worker_sg.id
#}

#output "aws_eip" {
#  value = aws_eip.nat.public_ip
#}