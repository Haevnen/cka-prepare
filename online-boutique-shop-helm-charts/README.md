# Online Boutique Shop on Kubernetes

This project deploys a small online store to a Kubernetes cluster using the
manifest in [`online-shop-config.yaml`](online-shop-config.yaml). The workloads
are based on [`Google's Online Boutique microservices demo`](https://github.com/GoogleCloudPlatform/microservices-demo) 

## What's Included

The application is split into services that communicate over Kubernetes
Services:

- `frontend` serves the store's web interface.
- `checkoutservice` coordinates checkout with cart, product catalog, currency,
	shipping, email, and payment services.
- `cartservice` stores cart data in `redis-cart`.
- `productcatalogservice` provides the product catalog.
- `recommendationservice` and `adservice` provide product recommendations and
	advertisements.
- `currencyservice`, `shippingservice`, `emailservice`, and `paymentservice`
	provide supporting checkout functions.

Most services are exposed internally as `ClusterIP` Services. The frontend is
exposed as a `NodePort` on port `32000`.

![alt text](images/architecture.png)

## Optimization

- We have 10 similar Deployment and Service Configurations
- Create **_Reusable K8s configuration_** for these services via Helm Chart
  + 1 blueprint for Deployment and Service
  + set values for individual microservices

## Helm Chart Layout

- `online-boutique-shop/` is the umbrella chart root.
- `online-boutique-shop/charts/microservice/` is the reusable chart for core
	application services.
- `online-boutique-shop/charts/redis/` is the separate Redis chart.
- `online-boutique-shop/values/` contains per-service overrides, Redis values,
	and `umbrella.yaml` for the combined release.
- `online-boutique-shop/values.yaml` contains the umbrella chart defaults;
	Helm loads this file automatically.

## Install Redis Separately

To manage Redis as its own Helm release, run from this directory:

```sh
helm upgrade --install redis-cart ./online-boutique-shop/charts/redis \
	-f ./online-boutique-shop/values/redis-cart.yaml
```

This creates the `redis-cart` Deployment and Service. The app services can
then be installed as separate releases using their values files, for example:

```sh
helm upgrade --install emailservice ./online-boutique-shop/charts/microservice \
	-f ./online-boutique-shop/values/emailservice.yaml
```

To install Redis and all core services as separate Helm releases, use the
helper script. It installs Redis first, then each service in sequence:

```sh
bash ./scripts/install-services.sh
```

Pass a namespace as the first argument to use a namespace other than `default`:

```sh
bash ./scripts/install-services.sh online-boutique
```

The script uses `helm upgrade --install`, so it can be run again to apply
updated values to existing releases.

## Install the Whole Shop as One Release

The umbrella chart installs all application services and Redis under one Helm
release. Build its local chart dependencies, then install it:

```sh
helm dependency update ./online-boutique-shop
helm upgrade --install online-boutique ./online-boutique-shop \
	-f ./online-boutique-shop/values/umbrella.yaml
```

To inspect the generated Kubernetes resources without installing them:

```sh
helm template online-boutique ./online-boutique-shop \
	-f ./online-boutique-shop/values/umbrella.yaml
```

Choose either the standalone Redis workflow or the umbrella workflow in a
namespace. Do not install both there: both create resources named `redis-cart`.

The Redis chart currently uses `emptyDir` storage for a simple demo. Its data
does not persist if the Redis pod is replaced.