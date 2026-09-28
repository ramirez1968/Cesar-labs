variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix/tag resources"
  type        = string
  default     = "cesars-labs"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cesars-labs-eks"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS managed node group (keep small for lab cost)"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the app image"
  type        = string
  default     = "simple-flask-app"
}

variable "github_org" {
  description = "GitHub org/user that owns the repo (for OIDC trust policy)"
  type        = string
  default     = "ramirez1968"
}

variable "github_repo" {
  description = "GitHub repo name (for OIDC trust policy)"
  type        = string
  default     = "Cesar-labs"
}

variable "github_owner_id" {
  type    = string
  default = "160644695"
}

variable "github_repo_id" {
  type    = string
  default = "1366726737"
}
