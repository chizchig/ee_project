output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "external_subnet_ids" {
  value = [for subnet in aws_subnet.external_subnets : subnet.id]
}

output "internal_subnet_ids" {
  value = [for subnet in aws_subnet.internal_subnets : subnet.id]
}

output "external_route_table_ids" {
  value = [for rt in aws_route_table.external_route_tables : rt.id]
}

output "internal_route_table_ids" {
  value = [for rt in aws_route_table.internal_route_tables : rt.id]
}

output "aws_security_group_id" {
  value = aws_security_group.aurora_sg
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}


output "jenkins_role_arn" {
  value = aws_iam_role.jenkins_role.arn
}
  


  



