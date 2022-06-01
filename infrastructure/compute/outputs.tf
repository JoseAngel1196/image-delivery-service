output "jumphost_ip" {
  value = aws_instance.ec2-bastion-host-image-delivery-service.public_ip
}

# output "private_ip" {
#   value = aws_instance.ec2-private-host-image-delivery-service[0].private_ip
# }