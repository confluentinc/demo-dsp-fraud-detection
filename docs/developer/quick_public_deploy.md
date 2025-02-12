### AUTH Quick
```bash
export AWS_ACCOUNT_ID="550017254839"
export AWS_REGION="us-west-2"
export AWS_ACCESS_KEY_ID="AKIAYAD4VIW3ZJ5W52HI"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_KEYPAIR_NAME="spencer-aws-keypair"
export AWS_ROLE_NAME=$(aws sts get-caller-identity --query "Arn" --output text | cut -d'/' -f2)
export AWS_CLUSTER_NAME=$(aws eks list-clusters --region ${AWS_REGION} --output json | jq -r '.clusters[0]')


export DOCKER_IMAGE_NAME="fraud-webapp"
export DOCKER_IMAGE_TAG="latest"
export DOCKER_REPO_NAMESPACE="demo"

export PRIVATE_DOCKER_HOST_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export PRIVATE_DOCKER_REPO_URL="${PRIVATE_DOCKER_HOST_URL}/${DOCKER_REPO_NAMESPACE}"
export PRIVATE_DOCKER_IMAGE_URL="${PRIVATE_DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

export PUBLIC_DOCKER_HOST_URL="public.ecr.aws/v3a9u0p7"
export PUBLIC_DOCKER_REPO_URL="${PUBLIC_DOCKER_HOST_URL}/${DOCKER_REPO_NAMESPACE}"
export PUBLIC_DOCKER_IMAGE_URL="${PUBLIC_DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${PUBLIC_DOCKER_HOST_URL}
aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_CLUSTER_NAME}
kubectl config set-context --current --namespace=default
```




### REDEPLOY AFTER YOU HAVE AUTHED

```bash
docker buildx build --platform linux/amd64 -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --load -f ./../../webapp/Dockerfile ./../../webapp
sleep 1
docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${PUBLIC_DOCKER_IMAGE_URL}
sleep 1
docker push ${PUBLIC_DOCKER_IMAGE_URL}
sleep 1
kubectl delete events --all -n defualt
kubectl delete deployment --all -n default
sleep 3
kubectl apply -f ../../resources/frauddemo.deployment.yaml
```

### VIEW LOGS AFTER DEPLOY

```bash
export POD_LOGS=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
echo $POD_LOGS
kubectl get pods
kubectl logs ${POD_LOGS}
```


### PORT FORWARD TO LOCALHOST AFTER LOGS ARE HEALTHY

```bash
export POD_PORT_FORWARD=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
 -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
echo $POD_PORT_FORWARD
kubectl port-forward pod/${POD_PORT_FORWARD} 8000:8000
```
