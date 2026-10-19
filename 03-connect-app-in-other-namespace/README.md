# Connect app in other namespace

- Imagine you have several services running in different namespace
  + How can you get the endpoint to test connection to other service, such as red-service in manufacturing namespace

```shell
controlplane ~ ➜  kubectl get svc -A 
NAMESPACE       NAME               TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
default         kubernetes         ClusterIP      10.43.0.1       <none>           443/TCP                      14m
dev             redis-db-service   ClusterIP      10.43.163.154   <none>           6379/TCP                     7m43s
finance         payroll-service    NodePort       10.43.101.174   <none>           8080:30083/TCP               7m43s
kube-system     kube-dns           ClusterIP      10.43.0.10      <none>           53/UDP,53/TCP,9153/TCP       14m
kube-system     metrics-server     ClusterIP      10.43.48.91     <none>           443/TCP                      14m
kube-system     traefik            LoadBalancer   10.43.230.111   10.244.102.206   80:32007/TCP,443:30307/TCP   13m
manufacturing   red-service        NodePort       10.43.87.97     <none>           8080:30080/TCP               7m43s
marketing       blue-service       NodePort       10.43.197.231   <none>           8080:30082/TCP               7m43s
marketing       redis-db-service   NodePort       10.43.1.52      <none>           6379:30645/TCP               7m43s
```

- Solution:
  + `<service-name>.<namespace>:<service-port> 
    - E.g., `red-service.manufacturing:8080` , `redis-db-service.dev:6379` ...