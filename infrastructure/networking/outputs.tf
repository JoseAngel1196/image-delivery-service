output "public_subnets" {
  description = "public subnets without the nat gateway"
  value       = [aws_subnet.public_subnet.*.id[1]]
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "public_security_group" {
  value = aws_security_group.security-group-image-delivery-service.id
}