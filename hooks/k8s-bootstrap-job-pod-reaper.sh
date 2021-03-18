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

NAMESPACE="${NAMESPACE_PREFIX}${ONDEMAND_USERNAME}"

TMPFILE=$(mktemp "/tmp/k8-bootstrap-job-pod-reaper-${ONDEMAND_USERNAME}.XXXXXX")
cat > "$TMPFILE" <<EOF
# allow job-pod-reaper to see this namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: "$ONDEMAND_USERNAME-job-pod-reaper-rolebinding"
  namespace: "$NAMESPACE"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: job-pod-reaper
subjects:
- kind: ServiceAccount
  name: job-pod-reaper
  namespace: job-pod-reaper
EOF

export PATH=/usr/local/bin:/bin:$PATH
kubectl apply -f "$TMPFILE"
rm -f "$TMPFILE"
