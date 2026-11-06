#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ ! -x ./cadastro ]]; then
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  bash compilar.sh
fi
mkdir -p "$HOME/Library/Application Support/Torresmo/Pessoas"
exec ./cadastro "$HOME/Library/Application Support/Torresmo/Pessoas"
