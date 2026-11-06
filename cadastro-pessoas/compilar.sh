#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v hbmk2 >/dev/null || { echo 'Instale Harbour: brew install harbour'; exit 1; }
hbmk2 cadastro.hbp
