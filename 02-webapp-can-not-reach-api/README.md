# Problem

- Imagine your team operate a 3-tier web application with `web`, `api` and `db`
- And you are notified that the web application can not reach the api Service

## Debug

- First check if the problem is DNS resolution (can't resolve hostname) or Service-to-Pod routing

  + Run busybox Pod to validate DNS working `kubectl run debug --image=busybox --rm -it --restart=Never -- sh`
  
  + And then make HTTP request to internal Service `wget -qO- --timeout=3 http://api` (-0- : send the response body to stdout)

    ![alt text](images/debug.png)

  + DNS can resolve the hostname `nginx-service` to IP address -> DNS is working

- Second, check if the Service has healthy backend endpoints `kubectl get endpoints nginx-service`

    ![alt text](images/debug2.png)

    + Service currently has no backend Pods to send traffic to

- Finally, double-check the Service selector and Pod's label -> there is a mismatch

    ![alt text](images/debug3.png)

- Update the Service's selector and re-check the endpoint

    ![alt text](images/debug4.png)

## Another potential problem

- Web application and API service is in different namespace. So it can't resolve the IP address of Service

  ```shell
  / # nslookup nginx-service
    Server:10.96.0.10
    Address:10.96.0.10:53

    ** server can't find nginx-service.fe.svc.cluster.local: NXDOMAIN

    ** server can't find nginx-service.svc.cluster.local: NXDOMAIN

    ** server can't find nginx-service.cluster.local: NXDOMAIN

    ** server can't find nginx-service.svc.cluster.local: NXDOMAIN

    ** server can't find nginx-service.cluster.local: NXDOMAIN

    ** server can't find nginx-service.fe.svc.cluster.local: NXDOMAIN
  ```

- In this case, `nginx-service` is in `default` namespace. So, we have to use its fully qualified DNS name `nginx-service.default.svc.cluster.local`

  ![alt text](images/debug5.png)