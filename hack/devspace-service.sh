#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

session="domrank-devspace"
log_file="/tmp/devspace.log"
ssh_host="domrank.devspace"
ssh_ready_pattern="to connect via SSH"
startup_timeout_secs=120

usage() {
  echo "usage: $0 {up|down|status}" >&2
  exit 1
}

print_log() {
  if [[ -f "${log_file}" ]]; then
    sed '/^[0-9]\{4\}\//d' "${log_file}"
  else
    echo "none"
  fi
}

wait_for_ssh() {
  local started_at now line_count offset
  started_at="$(date +%s)"
  offset=0

  while true; do
    if [[ -f "${log_file}" ]]; then
      line_count="$(wc -l < "${log_file}")"
      if (( line_count > offset )); then
        sed -n "$((offset + 1)),${line_count}p" "${log_file}" | grep -vE '^[0-9]{4}/' || true
        offset="${line_count}"
      fi
      if grep -q "${ssh_ready_pattern}" "${log_file}"; then
        echo "DevSpace is ready. Run 'make ssh' to connect or 'make code' to open VS Code."
        return 0
      fi
    fi

    if ! tmux has-session -t "${session}" 2>/dev/null; then
      echo "devspace exited before SSH was ready"
      return 1
    fi

    now="$(date +%s)"
    if (( now - started_at >= startup_timeout_secs )); then
      echo "ssh is not ready yet; continuing in background"
      echo "attach: tmux attach -t ${session}"
      echo "log: ${log_file}"
      return 0
    fi

    sleep 1
  done
}

up() {
  if tmux has-session -t "${session}" 2>/dev/null; then
    echo "devspace already running: ${session}"
    return 0
  fi

  rm -f "${log_file}"
  tmux new-session -d -s "${session}" -c "${repo_root}" \
    "sh -lc 'devspace dev 2>&1 | tee -a ${log_file}'"

  echo "started: tmux attach -t ${session}"
  echo "log: ${log_file}"
  wait_for_ssh
}

down() {
  tmux kill-session -t "${session}" 2>/dev/null || true
  pkill -f '^devspace ' 2>/dev/null || true
  sleep 1

  cd "${repo_root}"
  devspace purge
}

status() {
  local pid
  pid="$(pgrep -f '^devspace dev$' | head -n 1 || true)"

  if tmux has-session -t "${session}" 2>/dev/null; then
    echo "status: running"
    if [[ -n "${pid}" ]]; then
      echo "pid: ${pid}"
    fi
    echo
    print_log
  else
    echo "status: stopped"
  fi
}

case "${1:-}" in
  up)
    up
    ;;
  down)
    down
    ;;
  status)
    status
    ;;
  *)
    usage
    ;;
esac
