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

  cluster_name       = module.eks.cluster_name
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "addons" {
  source             = "./modules/addons"
  cluster_name       = module.eks.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  aws_region         = var.aws_region
  enable_gateway_api = true

  depends_on = [module.node_groups]
}

module "argocd" {
  source     = "./modules/argocd"
  depends_on = [module.eks, module.node_groups]
}

module "lbc_oicd" {
  source = "./modules/lbc_oicd"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}


module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}
