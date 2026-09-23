# Ansible: AWS infra for simple-flask-app

Provisions the same stack as the Terraform version (see `../terraform/`),
using Ansible + the `amazon.aws` / `community.aws` collections instead:

- VPC (2 AZs, public + private subnets, 1 NAT gateway to keep cost down)
- EKS cluster + a small managed node group (defaults to 1x `t3.small`)
- ECR repository for the app image
- GitHub Actions OIDC federation + IAM role so the pipeline can deploy
  without stored AWS keys, plus the EKS access entry so `kubectl` works
  from the pipeline

## Honest note on tooling fit
Ansible's AWS collections cover VPC/EKS/ECR/IAM well, but there's no
native module for creating an IAM **OIDC identity provider** itself
(unlike Terraform, which has a clean resource for this). `04-github-oidc.yml`
handles that one piece by shelling out to the AWS CLI, with an idempotency
check first so re-running the playbook doesn't fail or duplicate it.
Everything else uses proper Ansible modules.

## Cost heads-up
Same as the Terraform version: this creates real, billed AWS resources
— the EKS control plane (~$0.10/hr, ~$73/mo flat) plus one small EC2
node and a NAT gateway (~$0.045/hr). **Run `teardown.yml` when you're
done with a session** to avoid paying for an idle cluster.

## Prerequisites
```bash
pip install --break-system-packages boto3 botocore
ansible-galaxy collection install -r requirements.yml
```
AWS credentials should already be configured (`aws configure`), same as
you set up earlier for `eksctl`.

## Usage

Run the whole stack in order:
```bash
ansible-playbook site.yml
```

Or run playbooks individually (each depends on the ones before it,
since later playbooks read variables the earlier ones generate into
`generated_vars.yml` / `generated_eks_vars.yml`):
```bash
ansible-playbook 01-vpc.yml
ansible-playbook 02-ecr.yml
ansible-playbook 03-eks.yml
ansible-playbook 04-github-oidc.yml
```

## After running

1. `03-eks.yml` already runs `aws eks update-kubeconfig` for you, so
   `kubectl get nodes` should work immediately after.
2. Get the ECR repository URL:
   ```bash
   aws ecr describe-repositories --repository-names simple-flask-app \
     --query "repositories[0].repositoryUri" --output text
   ```
   Update `../k8s/deployment.yaml`'s image field with it, then:
   ```bash
   kubectl apply -f ../k8s/deployment.yaml
   kubectl apply -f ../k8s/service.yaml
   ```
3. `04-github-oidc.yml` prints the role ARN to add as a GitHub secret:
   - Repo → Settings → Secrets and variables → Actions
   - New secret named `AWS_ROLE_ARN`, value from the playbook output
4. Update `../.github/workflows/deploy.yml`'s `AWS_REGION` and
   `EKS_CLUSTER_NAME` to match `vars.yml`.

## Tear down

```bash
ansible-playbook teardown.yml
```
