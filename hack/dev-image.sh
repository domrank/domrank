#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dev_image="${DEV_IMAGE:-ghcr.io/domrank/domrank-dev}"
devspace_user_home="${DEVSPACE_USER_HOME:-${HOME}}"
local_extensions_dir="${devspace_user_home}/.vscode-server/extensions"
recommendations_file="${repo_root}/.vscode/extensions.json"
staging_dir="${repo_root}/.devspace/dev-image/vscode-server/extensions"

stage_recommended_extensions() {
  mkdir -p "${staging_dir}"
  rm -rf "${staging_dir:?}/"*

  if [[ ! -f "${recommendations_file}" ]]; then
    echo "Skipping VS Code extension staging: ${recommendations_file} does not exist."
    return 0
  fi

  if [[ ! -d "${local_extensions_dir}" ]]; then
    echo "Skipping VS Code extension staging: ${local_extensions_dir} does not exist."
    return 0
  fi

  mapfile -t recommended_ids < <(jq -r '.recommendations[]?' "${recommendations_file}")

  if [[ "${#recommended_ids[@]}" -eq 0 ]]; then
    echo "Skipping VS Code extension staging: no recommended extensions configured."
    return 0
  fi

  for extension_id in "${recommended_ids[@]}"; do
    prefix="${extension_id}-"
    mapfile -t matching_dirs < <(
      find "${local_extensions_dir}" -maxdepth 1 -mindepth 1 -type d -name "${prefix}*" -printf '%f\n' \
        | sort -V
    )

    if [[ "${#matching_dirs[@]}" -eq 0 ]]; then
      echo "Skipping VS Code extension staging: no ${prefix}* directories found."
      continue
    fi

    latest_dir="${matching_dirs[-1]}"
    cp -a "${local_extensions_dir}/${latest_dir}" "${staging_dir}/"
    echo "Staged VS Code extension ${latest_dir}"
  done
}

cd "${repo_root}"
stage_recommended_extensions
docker build -f Dockerfile.dev -t "${dev_image}:latest" .
docker push "${dev_image}:latest"
