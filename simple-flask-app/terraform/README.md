# Terraform: AWS infra for simple-flask-app

Provisions everything needed to run and deploy this app on EKS:

- VPC (2 AZs, public + private subnets, 1 NAT gateway to keep cost down)
- EKS cluster + a small managed node group (defaults to 1x `t3.small`)
- ECR repository for the app image
- IAM OIDC federation + role so GitHub Actions can deploy without stored AWS keys
- EKS access entry mapping that role to `kubectl` permissions

## Cost heads-up
This creates real, billed AWS resources — mainly the EKS control plane
(~$0.10/hr, ~$73/mo flat) plus one small EC2 node and a NAT gateway
(~$0.045/hr). **Run `terraform destroy` when you're done with a session**
to avoid paying for an idle cluster. See the root README for cheaper
alternatives (Fargate, NodePort instead of LoadBalancer, etc).

## Prerequisites
- Terraform >= 1.6 installed
- AWS credentials configured locally (`aws configure`) with permissions to
  create VPCs, EKS, IAM, and ECR resources
- `kubectl` installed

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Review the plan carefully before typing `yes` — this creates ~40+ resources.

## After apply

1. Grab the outputs:
   ```bash
   terraform output
   ```

2. Point `kubectl` at the new cluster:
   ```bash
   aws eks update-kubeconfig --region $(terraform output -raw aws_region) \
     --name $(terraform output -raw eks_cluster_name)
   ```

3. Update `../k8s/deployment.yaml`'s image field with the ECR URL from
   `terraform output ecr_repository_url`, then:
   ```bash
   kubectl apply -f ../k8s/deployment.yaml
   kubectl apply -f ../k8s/service.yaml
   ```

4. Add the GitHub Actions role ARN as a repo secret:
   - Go to your repo → Settings → Secrets and variables → Actions
   - New secret named `AWS_ROLE_ARN`
   - Value: `terraform output -raw github_actions_role_arn`

5. Update `.github/workflows/deploy.yml`'s `AWS_REGION` and
   `EKS_CLUSTER_NAME` env values to match your Terraform outputs.

## Tear down

```bash
terraform destroy
```
