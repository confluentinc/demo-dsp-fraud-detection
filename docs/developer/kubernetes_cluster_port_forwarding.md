## Validate & Interact with Kubernetes Cluster
We need to allow our local computer to access the Kubernetes cluster via the AWS terminal to setup our port forwarding.

<details>
<summary>Validate Kubernetes Cluster Setup Terraform</summary>

1. Ensure that only one Kubernetes Cluster is being created
   ```bash
   export AWS_REGION="us-west-2" # set the correct AWS Region 
   aws eks list-clusters --region ${AWS_REGION} #
   ```
   **Expected Output:**
   
   Example of a successful output:
   ```text
   {
       "clusters": [
           "frauddetectiondemo-eks-cluster-<cluster-string-name>",
      ]
   }
   ```
   
   **Note:** You will need to press `ctrl c` after this is ran


2. Store the kubernetes cluster name so you can interact with it.
   ```bash
   export AWS_CLUSTER_NAME=$(aws eks list-clusters --region ${AWS_REGION} --output json | jq -r '.clusters[0]')
   echo $AWS_CLUSTER_NAME
   ```
   
   **Expected Output:**
   
   ```text
   frauddetectiondemo-eks-cluster-<cluster-string-name>
   ```
   
3. Update your local Kube config to enable `kubectl` command line client 
   ```bash
   aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_CLUSTER_NAME}
   ```

   **Expected Output:**

   ```text
   Added new context arn:aws:eks:<region-name>:<account-id>:cluster/<cluster-name> to kubeconfig
   ```

4. Validate you can access the Pod
   ```bash
   kubectl get nodes
   ```
   
   **Expected Output:**
   ```text
   NAME STATUS ROLES AGE VERSION ip-192-168-1-1.ec2.internal Ready  15m v1.25.6 ip-192-168-2-1.ec2.internal Ready  15m v1.25.6
   ```
5. Set working namespace to default
   ```bash
   kubectl config set-context --current --namespace=default
   ```
   **Expected Output:**
   ```text
   Context "<current-context>" modified.
   ```
6. Validate namespace is set to default
   ```bash
   kubectl config view --minify | grep namespace:
   ```
   
   **Expected Output:**
   ```text
   namespace: default
   ```
7. Validate the web application is running
   ```bash
   export POD_LOGS=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
     -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
   echo $POD_LOGS
   kubectl get pods
   kubectl logs ${POD_LOGS}
   ```
   
   **Expected Output**
   ```text
   10.0.11.94 - - [03/Feb/2025:19:03:03 +0000] "GET /health/ HTTP/1.1" 200 16 "-" "kube-probe/1.31+"
   ```

</details>

---

1. Port forward from Kubernetes Pod to LocalHost
   ```bash
   export POD_PORT_FORWARD=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
   echo $POD_PORT_FORWARD
   kubectl port-forward pod/${POD_PORT_FORWARD} 8000:8000
   ```

   **Expected Outputs:**
   ```text
   Forwarding from [::1]:8000 -> 8000
   ```