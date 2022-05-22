output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "nateway_subnet_id" {
  value = aws_nat_gateway.nat-gateway-image-delivery-service.subnet_id
}
