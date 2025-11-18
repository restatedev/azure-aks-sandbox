#!/usr/bin/env bash

set -euo pipefail

RESOURCE="$1"

# Use IMDS if ARM_USE_MSI is set to true
if [ "${ARM_USE_MSI:-false}" = "true" ]; then
  curl -s -H "Metadata: true" \
    "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=$RESOURCE" | jq -c '{
    "kind": "ExecCredential",
    "apiVersion": "client.authentication.k8s.io/v1beta1",
    "spec": {
      "interactive": false
    },
    "status": {
      "expirationTimestamp": (.expires_on | tonumber | strftime("%Y-%m-%dT%H:%M:%SZ")),
      "token": .access_token
    }
  }'
else
  # Use az cli for local development
  az account get-access-token -o json --resource "$RESOURCE" | jq -c '{
    "kind": "ExecCredential",
    "apiVersion": "client.authentication.k8s.io/v1beta1",
    "spec": {
      "interactive": false
    },
    "status": {
      "expirationTimestamp": (.expires_on | strftime("%Y-%m-%dT%H:%M:%SZ")),
      "token": .accessToken
    }
  }'
fi
