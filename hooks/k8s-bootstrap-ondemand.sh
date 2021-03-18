#!/bin/bash

ONDEMAND_USERNAME="$1"
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

source $HOOK_ENV

export PATH=/usr/local/bin:/bin:$PATH
NAMESPACE="${NAMESPACE_PREFIX}${ONDEMAND_USERNAME}"

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
YAML_DIR=${BASEDIR}/k8s-bootstrap

NAMESPACE_TMPFILE=$(mktemp "/tmp/k8-bootstrap-namespace-${ONDEMAND_USERNAME}.XXXXXX")
cat ${YAML_DIR}/namespace.yaml | envsubst > "$NAMESPACE_TMPFILE"

NETWORK_POLICY_TMPFILE=$(mktemp "/tmp/k8-bootstrap-network-policy-${ONDEMAND_USERNAME}.XXXXXX")
cat ${YAML_DIR}/network-policy.yaml | envsubst > "$NETWORK_POLICY_TMPFILE"

ROLEBINDING_TMPFILE=$(mktemp "/tmp/k8-bootstrap-rolebinding-${ONDEMAND_USERNAME}.XXXXXX")
cat ${YAML_DIR}/rolebinding.yaml | envsubst > "$ROLEBINDING_TMPFILE"

TMPFILE=$(mktemp "/tmp/k8-ondemand-bootstrap-${ONDEMAND_USERNAME}.XXXXXX")
cat "$NAMESPACE_TMPFILE" "$NETWORK_POLICY_TMPFILE" "$ROLEBINDING_TMPFILE" > "$TMPFILE"
kubectl apply -f "$TMPFILE"
rm -f "$NAMESPACE_TMPFILE" "$NETWORK_POLICY_TMPFILE" "$ROLEBINDING_TMPFILE" "$TMPFILE"

if [ "x$IMAGE_PULL_SECRET" != "x" ]; then
  kubectl create secret generic "$IMAGE_PULL_SECRET" --from-file=.dockerconfigjson="$REGISTRY_DOCKER_CONFIG_JSON" --type=kubernetes.io/dockerconfigjson -n "$NAMESPACE"
  kubectl patch serviceaccount default -n "$NAMESPACE" -p "{\"imagePullSecrets\": [{\"name\": \"${IMAGE_PULL_SECRET}\"}]}"
fi
