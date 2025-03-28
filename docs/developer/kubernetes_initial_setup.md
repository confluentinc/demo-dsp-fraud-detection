# Developer Documentation: Updating `kubeconfig` and Applying Deployment to AWS EKS

This guide outlines how to update your local `kubeconfig` for AWS EKS and deploy the `frauddemo.deployment.yaml` file to your cluster. All steps assume a macOS environment and bash commands executed from the macOS terminal.

---

## Prerequisites
Before you begin, ensure the following:
- [Install all prerequisite software](prerequisite_installations.md)
- [Set all relevant environment variables](get_and_set_environment_variables.md)
- You have administrator access to the EKS cluster.
- The `frauddemo.deployment.yaml` file is available in the current working directory.

--

## Step 1: List All Kubernetes Cluster Names
Set the correct AWS_REGION as a 

```bash
export AWS_REGION="us-west-2"
aws eks list-clusters --region ${AWS_REGION}
```

**Expected Output:**

Example of a successful output:
```text
{
    "clusters": [
        "cluster-1",
        "cluster-2",
        "cluster-3"
    ]
}
```

Figure out which cluster is the relevant index (starting at zero) and update the index of the following command

```bash
export AWS_CLUSTER_NAME=$(aws eks list-clusters --region ${AWS_REGION} --output json | jq -r '.clusters[0]')
```

```bash
echo $AWS_CLUSTER_NAME
```

Ensure you are using the AWS User so you have access to the resources in Kubernetes
```bash
aws sts get-caller-identity --query "Arn" --output text | cut -d'/' -f2
```

**Expected Output&&
```admin-user```


---

## Step 2: Update Local `kubeconfig` for AWS EKS

### Description
AWS EKS requires an updated `kubeconfig` file to communicate with your Kubernetes cluster. The `update-kubeconfig` command generates or updates the `kubeconfig` file with the specified cluster’s information.

### Clear Kube Config
```bash
> ~/.kube/config
```

### Command to Execute
```bash
aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_CLUSTER_NAME}
```

### Expected Output
- Confirmation that your `kubeconfig` is updated:
  ```
  Added new context arn:aws:eks:<region-name>:<account-id>:cluster/<cluster-name> to kubeconfig
  ```

### Example
```bash
aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_CLUSTER_NAME}
```

### Test Config
```bash
cat ~/.kube/config
```

---

## Step 3: Verify `kubeconfig` is Updated

### Description
Ensure communication with the cluster is successful by listing the nodes in the EKS cluster.

### Command to Verify
```bash
kubectl get nodes
```

### Expected Output
A list of nodes in the cluster, such as:
```text
NAME STATUS ROLES AGE VERSION ip-192-168-1-1.ec2.internal Ready  15m v1.25.6 ip-192-168-2-1.ec2.internal Ready  15m v1.25.6
```

---

## Step 4. Ensure you are working in default namespace
### Command to Ensure Default Namespace is Set
```bash
kubectl config set-context --current --namespace=default
```

### Expected Output
Confirmation that the namespace has been set to `default`:
```plaintext
Context "<current-context>" modified.
```

### Command to Verify Current Namespace
```bash
kubectl config view --minify | grep namespace:
```

### Expected Output
Confirmation that the current namespace is `default`:



## Step 3: Apply `frauddemo.deployment.yaml`

### Description
Once the `kubeconfig` is updated, apply the specified `frauddemo.deployment.yaml` to the EKS cluster using `kubectl apply`.

### Command to Execute
```bash
kubectl apply -f ../../resources/frauddemo.deployment.yaml
```

### Expected Output
Confirmation that the deployment configuration has been applied:
```plaintext
deployment.apps/frauddemo created
```

---

## Step 4: Verify Deployment Works

### Description
Ensure the deployment was successful by checking the status of pods created by the deployment.

### Command to Verify
```bash
kubectl get pods
```

### Expected Output
A list of pods with the `Running` or `Completed` status:
```plaintext
NAME READY STATUS RESTARTS AGE frauddemo-5d9b89f9c7-m9b7z 1/1 Running 0 2m frauddemo-5d9b89f9c7-k3ghx 1/1 Running 0 2m
```


---

## Notes
- Replace all placeholder values (`<region-name>` and `<cluster-name>`) with proper names.
- If any errors occur during the commands, ensure your AWS CLI and `kubectl` configurations align with the required permissions and configurations.
