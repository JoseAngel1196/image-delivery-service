module "networking" {
  source           = "./networking"
  cidr_block       = var.cidr_block
  max_subnets      = 18
  private_sn_count = 12
  public_sn_count  = 6
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
  source                            = "./compute"
  public_subnets                    = module.networking.public_subnets
  private_subnets                   = module.networking.private_subnets
  web_application_security_group    = module.networking.web_application_security_group
  application_server_security_group = module.networking.application_server_security_group
  public_key_path                   = var.public_key_path
  private_key_path                  = var.private_key_path
  instance_iam_name                 = module.iam.instance_iam_name
  alb_public_security_group         = module.networking.alb_public_security_group
  alb_internal_security_group       = module.networking.alb_internal_security_group
  vpc_id                            = module.networking.vpc_id
}
