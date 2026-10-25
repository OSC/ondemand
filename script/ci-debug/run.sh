#!/usr/bin/env bash
# Run one command without replacing its result with a diagnostic failure.
set -uo pipefail
label="${1:-}"
if [[ ! "$label" =~ ^[a-zA-Z0-9_-]+$ || $# -lt 2 ]]; then
  printf '%s\n' 'Usage: run.sh LABEL COMMAND [ARGUMENT ...]' >&2
  exit 2
fi
shift
: "${CI_DEBUG_DIR:?Set CI_DEBUG_DIR to an artifact directory}"
mkdir -p "$CI_DEBUG_DIR" || exit 2
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$CI_DEBUG_DIR/started-at" ]]; then
  date +%s > "$CI_DEBUG_DIR/started-at"
fi
bash "$script_dir/collect.sh" "$label-before" || true

sample_resources() {
  while :; do
    date -u '+%Y-%m-%dT%H:%M:%SZ'
    ps -eo pid,ppid,stat,rss,comm --sort=-rss | head -25
    for file in memory.current memory.events pids.current; do
      if [[ -r "/sys/fs/cgroup/$file" ]]; then
        printf '%s: ' "$file"
        cat "/sys/fs/cgroup/$file"
      fi
    done
    sleep 5
  done
}
finish() {
  result=$1
  trap - EXIT
  kill "$sampler" 2>/dev/null || true
  wait "$sampler" 2>/dev/null || true
  bash "$script_dir/collect.sh" "$label-after" || true
  printf '%s\n' "$result" > "$CI_DEBUG_DIR/$label-status.txt"
  exit "$result"
}
sample_resources > "$CI_DEBUG_DIR/$label-resources.log" 2>&1 &
sampler=$!
trap 'finish "$?"' EXIT
"$@" 2>&1 | tee "$CI_DEBUG_DIR/$label-output.log"
result=${PIPESTATUS[0]}
finish "$result"
