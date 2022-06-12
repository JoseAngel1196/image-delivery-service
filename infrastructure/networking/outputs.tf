output "public_subnets" {
  description = "public subnets w/ the nat gateway"
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "web_application_security_group" {
  value = aws_security_group.security-group-instance-image-delivery-service.id
}

output "application_server_security_group" {
  value = aws_security_group.security-group-application-server-image-delivery-service.id
}

output "alb_public_security_group" {
  value = aws_security_group.security-group-alb-public-facing-image-delivery-service.id
}

output "alb_internal_security_group" {
  value = aws_security_group.security-group-alb-internal-image-delivery-service.id
}

output "efs_security_group" {
  value = aws_security_group.security-group-efs-image-delivery-service.id
}

output "vpc_id" {
  value = local.vpc_id
}