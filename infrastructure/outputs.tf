output "ssh_private_key_pem" {
  value     = module.security.ssh_private_key_pem
  sensitive = true
}

output "ssh_public_key_pem" {
  value     = module.security.ssh_public_key_pem
  sensitive = true
}

output "public_subnets" {
  value = module.networking.public_subnets
}

output "private_subnets" {
  value = module.networking.private_subnets
}

output "jumphost_ip" {
  value = module.compute.jumphost_ip
}
