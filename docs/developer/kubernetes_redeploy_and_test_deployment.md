

- Delete all existing
```bash
kubectl delete event --all -n defualt
kubectl delete deployment --all -n default
```

- Deploy deployment
```bash
kubectl apply -f ../../resources/frauddemo.deployment.yaml
```

- View Deployment events
```bash
kubectl get events
```

- View Deployment logs
```bash
export POD_LOGS=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
echo $POD_LOGS
kubectl get pods
kubectl logs ${POD_LOGS}
```

- SSH into pod
```bash
export SSH_POD=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
echo $SSH_POD
kubectl describe pod ${SSH_POD}
kubectl exec -it ${SSH_POD} -c fraud-demo -n default -- /bin/bash
```

- View Pod Env Vars
```bash
kubectl describe deployment fraud-demo | grep -A5 -i env
```

- View Config Maps
```bash
kubectl get configmap
kubectl get configmaps fraud-demo-config -o yaml
```

- Create Port Forward to POD
```bash
export POD_PORT_FORWARD=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
 -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
echo $POD_PORT_FORWARD
kubectl port-forward pod/${POD_PORT_FORWARD} 8000:8000
```