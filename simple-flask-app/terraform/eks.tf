module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # Automatically maps the calling identity (you) as a cluster admin
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD" # AL2 AMIs were discontinued Nov 2025
      instance_types = [var.node_instance_type]
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Project = var.project_name
  }
}

# NOTE: no separate OIDC provider resource here — the eks module above
# already creates one internally (for IRSA). github-oidc.tf creates a
# SEPARATE, distinct OIDC provider for GitHub Actions federation itself,
# which is unrelated to this one and still needed.
