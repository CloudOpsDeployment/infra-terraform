module "vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "node_groups" {
  source = "./modules/node_groups"

  cluster_name       = var.cluster_name
  node_instance_type = var.node_instance_type
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "addons" {
    source = "./modules/addons"
    cluster_name = var.cluster_name
    oidc_provider_arn = module.eks.oidc_provider_arn
    oidc_provider_url = module.eks.oidc_provider_url

    depends_on = [module.node_groups]
}