output "jumphost_ip" {
  value = aws_instance.ec2-bastion-host-image-delivery-service.public_ip
}
