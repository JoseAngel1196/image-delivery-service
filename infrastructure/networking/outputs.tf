output "public_subnets" {
  description = "public subnets without the nat gateway"
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "public_security_group" {
  value = aws_security_group.security-group-instance-image-delivery-service.id
}

output "alb_security_group" {
  value = aws_security_group.security-group-alb-image-delivery-service.id
}

output "vpc_id" {
  value = local.vpc_id
}