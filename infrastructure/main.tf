module "networking" {
  source           = "./networking"
  cidr_block       = var.cidr_block
  max_subnets      = 3
  private_sn_count = 2
  public_sn_count  = 1
  public_cidrs     = [for i in range(2, 256, 2) : cidrsubnet(var.cidr_block, 8, i)]
  private_cidrs    = [for i in range(1, 256, 2) : cidrsubnet(var.cidr_block, 8, i)]
}
