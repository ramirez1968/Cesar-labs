# simple-flask-app

A minimal Flask app with health checks, containerized and ready for EKS.

## Endpoints
- `GET /` — hello world + hostname/version
- `GET /healthz` — health check (used by k8s probes)
- `GET /api/info` — env/pod info

## Run locally
```bash
pip install -r requirements.txt
python app.py
# visit http://localhost:8080
```

## Build the Docker image
```bash
docker build -t simple-flask-app:latest .
docker run -p 8080:8080 simple-flask-app:latest
```

## Push to ECR
```bash
# Set these to your values
AWS_ACCOUNT_ID=<your-account-id>
AWS_REGION=<your-region>
REPO_NAME=simple-flask-app

# Create the repo (one-time)
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION

# Auth docker to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Tag and push
docker tag simple-flask-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest
```

## Deploy to EKS
Update `k8s/deployment.yaml` — replace `REPLACE_WITH_YOUR_ECR_IMAGE_URI` with your
pushed image URI, then:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

kubectl get pods
kubectl get svc simple-flask-app   # wait for EXTERNAL-IP, then curl it
```
