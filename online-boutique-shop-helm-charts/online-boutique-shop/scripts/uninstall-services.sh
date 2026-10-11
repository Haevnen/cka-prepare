#!/usr/bin/env bash
set -euo pipefail

namespace="${1:-default}"

releases=(
  frontend
  checkoutservice
  cartservice
  recommendationservice
  productcatalogservice
  currencyservice
  adservice
  shippingservice
  paymentservice
  emailservice
)

for release in "${releases[@]}"; do
  helm uninstall "${release}" \
    --namespace "${namespace}" \
    --ignore-not-found
done

helm uninstall redis-cart \
  --namespace "${namespace}" \
  --ignore-not-found

printf 'Uninstalled all standalone services from namespace %s.\n' "${namespace}"