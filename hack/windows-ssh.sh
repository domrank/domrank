#!/usr/bin/env bash

set -euo pipefail

host_name="${1:-domrank.devspace}"

source_config_path="${HOME}/.ssh/devspace_config"
source_key_dir="${HOME}/.devspace/ssh"
local_config_path="${HOME}/.ssh/config"
include_line="Include ~/.ssh/devspace_config"

ensure_include_line() {
  local config_path="$1"
  local tmp_file

  if [[ ! -f "${config_path}" ]]; then
    touch "${config_path}"
  fi

  tmp_file="$(mktemp)"
  {
    printf '%s\n' "${include_line}"
    rg -vxF "${include_line}" "${config_path}" || true
  } > "${tmp_file}"
  mv "${tmp_file}" "${config_path}"
}

sync_windows_ssh() {
  local windows_home_win windows_home_wsl windows_ssh_dir windows_key_dir
  local windows_config_path windows_include_path windows_identity_dir

  windows_home_win="$(powershell.exe -NoProfile -Command '$env:USERPROFILE' | tr -d '\r')"
  windows_home_wsl="$(wslpath -u "${windows_home_win}")"
  windows_ssh_dir="${windows_home_wsl}/.ssh"
  windows_key_dir="${windows_home_wsl}/.devspace/ssh"
  windows_config_path="${windows_ssh_dir}/config"
  windows_include_path="${windows_ssh_dir}/devspace_config"
  windows_identity_dir="$(printf '%s/.devspace/ssh' "${windows_home_win}" | tr '\\' '/')"

  mkdir -p "${windows_ssh_dir}" "${windows_key_dir}"

  # Copy keys with secure permissions.
  while IFS= read -r -d '' key_file; do
    install -m 600 "${key_file}" "${windows_key_dir}/$(basename "${key_file}")"
  done < <(find "${source_key_dir}" -maxdepth 1 -type f -print0)

  sed \
    -e "s|${HOME}/.devspace/ssh/|${windows_identity_dir}/|g" \
    -e "s|~/.devspace/ssh/|${windows_identity_dir}/|g" \
    "${source_config_path}" > "${windows_include_path}"

  if [[ ! -f "${windows_config_path}" ]]; then
    touch "${windows_config_path}"
  fi

  ensure_include_line "${local_config_path}"
  ensure_include_line "${windows_config_path}"
  chmod 600 "${local_config_path}"
  chmod 600 "${windows_config_path}"

  echo "Synced DevSpace SSH config and keys to Windows SSH directory."
}

check_windows_ssh() {
  local remote_hostname

  if ! command -v ssh >/dev/null 2>&1; then
    echo "ssh client is required for connectivity checks." >&2
    exit 1
  fi

  remote_hostname="$(ssh -F "${source_config_path}" -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new "${host_name}" hostname)"
  echo "Connected to '${host_name}' successfully. Remote hostname: ${remote_hostname}"
}

if [[ -z "${WSL_DISTRO_NAME:-}" ]]; then
  # Non-WSL environments do not need Windows-side SSH sync.
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  echo "powershell.exe is required in WSL to access Windows SSH config." >&2
  exit 1
fi

if ! command -v wslpath >/dev/null 2>&1; then
  echo "wslpath is required in WSL to access Windows SSH config." >&2
  exit 1
fi

if [[ ! -f "${source_config_path}" ]]; then
  echo "Missing ${source_config_path}. Run 'make up' first." >&2
  exit 1
fi

if [[ ! -d "${source_key_dir}" ]]; then
  echo "Missing ${source_key_dir}. Run 'make up' first." >&2
  exit 1
fi

if ! rg -q "^Host[[:space:]]+${host_name}([[:space:]]|$)" "${source_config_path}"; then
  echo "Host ${host_name} was not found in ${source_config_path}. Run 'make up' first." >&2
  exit 1
fi

sync_windows_ssh
check_windows_ssh
