#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
chart_root="${script_dir}/../online-boutique-shop"
namespace="${1:-default}"

services=(
  emailservice
  paymentservice
  shippingservice
  adservice
  currencyservice
  productcatalogservice
  recommendationservice
  cartservice
  checkoutservice
  frontend
)

helm upgrade --install redis-cart "${chart_root}/charts/redis" \
  --namespace "${namespace}" \
  --create-namespace \
  -f "${chart_root}/values/redis-cart.yaml"

for service in "${services[@]}"; do
  helm upgrade --install "${service}" "${chart_root}/charts/microservice" \
    --namespace "${namespace}" \
    -f "${chart_root}/values/${service}.yaml"
done

printf 'Installed all services into namespace %s.\n' "${namespace}"