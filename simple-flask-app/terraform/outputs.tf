output "ecr_repository_url" {
  description = "Push images here"
  value       = aws_ecr_repository.app.repository_url
}

output "eks_cluster_name" {
  description = "Use with: aws eks update-kubeconfig --name <this>"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "github_actions_role_arn" {
  description = "Paste this into your GitHub repo secret AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "aws_region" {
  value = var.aws_region
}
