module "networking" {
  source           = "./networking"
  cidr_block       = var.cidr_block
  max_subnets      = 4
  private_sn_count = 2
  public_sn_count  = 2
  public_cidrs     = [for i in range(2, 256, 2) : cidrsubnet(var.cidr_block, 8, i)]
  private_cidrs    = [for i in range(1, 256, 2) : cidrsubnet(var.cidr_block, 8, i)]
}

module "security" {
  source = "./security"
}

module "compute" {
  source          = "./compute"
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  public_security_group = module.networking.public_security_group
  ssh_key_name    = module.security.ssh_key_name
}
