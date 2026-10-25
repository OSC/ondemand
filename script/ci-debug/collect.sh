#!/usr/bin/env bash
# Best-effort, bounded snapshots. Do not dump environment variables or process argv.
set -uo pipefail
label="${1:-snapshot}"
if [[ ! "$label" =~ ^[a-zA-Z0-9_-]+$ ]]; then exit 2; fi
: "${CI_DEBUG_DIR:?Set CI_DEBUG_DIR to an artifact directory}"
mkdir -p "$CI_DEBUG_DIR" || exit 2
{
  date -u '+%Y-%m-%dT%H:%M:%SZ'
  uname -a
  git rev-parse HEAD
  ruby --version
  bundle --version
  for binary in "${CI_DEBUG_CHROME:-}" "${CI_DEBUG_CHROMEDRIVER:-}" google-chrome chromedriver; do
    if command -v "$binary" >/dev/null 2>&1; then timeout 5s "$binary" --version; fi
  done
  if command -v bundle >/dev/null; then bundle list; fi
  df -h . /dev/shm
  free -m
  ps -eo pid,ppid,stat,rss,comm --sort=-rss | head -25
  for file in memory.max memory.current memory.events pids.max pids.current; do
    if [[ -r "/sys/fs/cgroup/$file" ]]; then
      printf '%s: ' "$file"
      cat "/sys/fs/cgroup/$file"
    fi
  done
} > "$CI_DEBUG_DIR/$label-host.log" 2>&1

started="$(cat "$CI_DEBUG_DIR/started-at" 2>/dev/null || date +%s)"
now="$(date +%s)"
if command -v docker >/dev/null; then
  {
    timeout 10s docker version
    timeout 10s docker info --format 'Version={{.ServerVersion}} Driver={{.Driver}} CPUs={{.NCPU}} Memory={{.MemTotal}} Root={{.DockerRootDir}}'
    timeout 10s docker ps --all --format '{{.ID}} {{.Names}} {{.Image}} {{.Status}}'
    timeout 15s docker events --since "$started" --until "$now" --format '{{json .}}'
  } > "$CI_DEBUG_DIR/$label-docker.log" 2>&1
fi
if command -v sudo >/dev/null; then
  timeout 10s sudo -n journalctl --unit docker --since "@$started" --no-pager -n 1000 \
    > "$CI_DEBUG_DIR/$label-docker-journal.log" 2>&1 || true
  timeout 10s sudo -n dmesg --ctime 2>&1 | tail -200 > "$CI_DEBUG_DIR/$label-kernel.log" || true
fi
exit 0
