#!/usr/bin/env bash

set -euo pipefail

folder_uri="vscode-remote://ssh-remote+domrank.devspace/go/src/domrank"
code --folder-uri "${folder_uri}"
