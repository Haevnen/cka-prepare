# Diagnose and Resolve Stability Issues in a Go Application Deployment

## Problem
- Go application is deployed in the cluster. Simple HTTP server that consumes around `100MB` of memory per request
- The memory limit is set to `512MB`
- And it has made the application repeatedly crash after serving about half a dozen request
-> Find the root course and implement a fix

## Solution
- The application run a single pod deployment named `memhog`. And it's exposed via ClusterIP service named `memhog-service`

- I tried to get pod's log 
  ```shell
  laborant@k3s-01:~$ k logs memhog-6dc4b54cfb-4psx7
  2026/11/27 09:23:27 Starting server on port 8080...
  Request processed in 643.6622ms
  Request processed in 646.976258ms
  Request processed in 649.441786ms
  Request processed in 588.163364ms
  Request processed in 592.766697ms
  Request processed in 620.307333ms
  Request processed in 587.590372ms
  Request processed in 599.344164ms
  Request processed in 578.428031ms
  Request processed in 600.05594ms
  Request processed in 593.975692ms
  ```

- And inspect some information of pod. Pod is running but container has `CrashLoopBackOff` status with `OOMKilled` error (_crashLoopBackOff means that a container repeatedly starts, crashes and get restarted_) -> K8s waits increasingly longer between restart attempts

  ```shell
  laborant@k3s-01:~$ k describe pod memhog-6dc4b54cfb-4psx7
  Name:             memhog-6dc4b54cfb-4psx7
  Namespace:        default
  Priority:         0
  Service Account:  default
  Node:             k3s-01/172.16.0.2
  Start Time:       Fri, 27 Nov 2026 08:56:24 +0000
  Labels:           app=memhog
                    pod-template-hash=6dc4b54cfb
  Annotations:      <none>
  Status:           Running
  IP:               10.42.0.4
  IPs:
    IP:           10.42.0.4
  Controlled By:  ReplicaSet/memhog-6dc4b54cfb
  Containers:
    memhog:
    Container ID:   containerd://a51e4519deb58b3946a35fe98813e8938f14cca918eebb35cf845ee39b6f0593
    Image:          ghcr.io/iximiuz/labs/go-app-oom/memhog:v1.0.0
    Image ID:       ghcr.io/iximiuz/labs/go-app-oom/memhog@sha256:74abc3a004cd745171f90f241cc2ccdaf19466afb54840fb2a423fb4a86ecd31
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Fri, 27 Nov 2026 09:23:27 +0000
      Finished:     Fri, 27 Nov 2026 09:23:39 +0000
    Ready:          False
    Restart Count:  10
    Limits:
      cpu:     1
      memory:  512Mi
    Requests:
      cpu:        1
      memory:     512Mi
  ```

- a solution is to set env `GOMEMLIMIT` that will trigger the GC to clean the temporary memory when the memory hit the threshold -> Make Go GC a little bit more aggressive
```shell
       containers:                                                                
  3       - env:                                                                     
  2         - name: GOMEMLIMIT                                                       
  1           value: "350000000"                                                     
  41          image: ghcr.io/iximiuz/labs/go-app-oom/memhog:v1.0.0
```