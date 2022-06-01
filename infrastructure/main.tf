module "networking" {
  source           = "./networking"
  cidr_block       = var.cidr_block
  max_subnets      = 9
  private_sn_count = 8
  public_sn_count  = 1
  public_cidrs     = [for i in range(2, 256, 2) : cidrsubnet(var.cidr_block, 8, i)]
  private_cidrs    = [for i in range(1, 256, 2) : cidrsubnet(var.cidr_block, 8, i)]
}

module "iam" {
  source = "./iam"
}

module "s3" {
  source = "./s3"
}

module "compute" {
  source                = "./compute"
  public_subnets        = module.networking.public_subnets
  private_subnets       = module.networking.private_subnets
  public_security_group = module.networking.public_security_group
  public_key_path       = var.public_key_path
  private_key_path      = var.private_key_path
  instance_iam_name     = module.iam.instance_iam_name
  alb_security_group    = module.networking.alb_security_group
  vpc_id                = module.networking.vpc_id
}
