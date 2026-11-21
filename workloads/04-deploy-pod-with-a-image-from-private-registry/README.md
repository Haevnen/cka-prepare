# Deploy pod with a image from private registry

- To pull images from private registries, it requires authentication credentials
- And K8s stores this credentials as Secrets of a special type called `kubernetes.io/dockerconfigjson`
- So, there are two main steps 
  + step 1: create a secret that has authentication credentials with type `kubernetes.io/dockerconfigjson` 
  + step 2: refer this secret in Pod's manifest file

## Step 1: Create a secret

- Solution 1: if you have credentials info (like user/pass)

    + Run command to create secret
      ```shell
      kubectl create secret docker-registry SECRET_NAME \
      --docker-server=REGISTRY_DOMAIN \
      --docker-username=REGISTRY_USERNAME \
      --docker-password=REGISTRY_PASSWORD \
      --namespace=POD_NAMESPACE
      ```

- Solution 2: create secret via `~/.docker/config.json` file

    + If you don't have `~/.docker/config.json` file -> Run `docker login`

    + And then use imperative way

      ```shell
      kubectl create secret generic SECRET_NAME \
      --from-file=.dockerconfigjson=PATH_TO_CONFIG_JSON_FILE \
      --type=kubernetes.io/dockerconfigjson
      ```

      OR declarative way to create secret

      ```code
      apiVersion: v1
      kind: Secret
      metadata:
        name: SECRET_NAME
        namespace: POD_NAMESPACE
      type: kubernetes.io/dockerconfigjson
      data:
        .dockerconfigjson: BASE64_ENCODED_DOCKER_CONFIG_JSON
      ```

## Step 2: Refer secret in Pod's manifest file

- To make a Pod use a registry secret to pull images, use `imagePullImages` field

```code
apiVersion: v1
kind: Pod
metadata:
  name: POD_NAME
spec:
  containers:
  - name: CONTAINER_NAME
    image: PRIVATE_IMAGE
  imagePullSecrets:
  - name: SECRET_NAME
```