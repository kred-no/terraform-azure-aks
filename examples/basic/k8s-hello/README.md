# hello-kubernetes

```bash
# Source credentials file
export KUBECONFIG="./kubeconfig"

# Verify connection
kubectl get nodes

# Submit deployment
kubectl apply -f k8s-hello/deployment.yml

# Connect (port-forward) & then open browser at localhost:8080
kubectl port-forward $(kubectl get pod -l name=hello-kubernetes --no-headers | awk '{print $1}') 8080:8080

# Submit load-balancer service & verify service is exposed @public address
kubectl apply -f k8s-hello/service-loadbalancer.yml
kubectl get service

# Next steps requires "http_application_routing_enabled = true"
kubectl delete service hello-kubernetes
kubectl apply -f k8s-hello/service.yml
kubectl apply -f k8s-hello/ingress.yml
kubectl describe ingress hello-kubernetes

# Access deployment @Address
```