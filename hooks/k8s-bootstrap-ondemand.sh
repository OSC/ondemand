#!/bin/bash

export ONDEMAND_USERNAME="$1"
if [ "x${ONDEMAND_USERNAME}" = "x" ]; then
  echo "Must specify username"
  exit 1
fi
HOOK_ENV="$2"
if [ "x${HOOK_ENV}" = "x" ]; then
  echo "Must specify hook.env path"
  exit 1
fi

set -e

# shellcheck disable=SC1090
source "$HOOK_ENV"
# shellcheck disable=SC2046
export $(grep -Ev "^#" "$HOOK_ENV" | cut -d= -f1)

export PATH=/usr/local/bin:/bin:$PATH
export NAMESPACE="${NAMESPACE_PREFIX}${ONDEMAND_USERNAME}"

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
YAML_DIR="${BASEDIR}/k8s-bootstrap"
TMPFILE=$(mktemp "/tmp/k8-ondemand-bootstrap-${ONDEMAND_USERNAME}.XXXXXX")

envsubst < "${YAML_DIR}/namespace.yaml" > "$TMPFILE"
envsubst < "${YAML_DIR}/network-policy.yaml" >> "$TMPFILE"
envsubst < "${YAML_DIR}/rolebinding.yaml" >> "$TMPFILE"

kubectl apply -f "$TMPFILE"
rm -f "$TMPFILE"

if [ "x$IMAGE_PULL_SECRET" != "x" ]; then
  kubectl create secret generic "$IMAGE_PULL_SECRET" \
    --from-file=.dockerconfigjson="$REGISTRY_DOCKER_CONFIG_JSON" \
    --type=kubernetes.io/dockerconfigjson -n "$NAMESPACE" \
    -o yaml --dry-run=client | kubectl apply -f-
  kubectl patch serviceaccount default -n "$NAMESPACE" -p "{\"imagePullSecrets\": [{\"name\": \"${IMAGE_PULL_SECRET}\"}]}"
fi
