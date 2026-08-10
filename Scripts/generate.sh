#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [ ! -f "$SCRIPT_DIR/project.env" ]; then
  echo "Missing Scripts/project.env. Copy Scripts/project.env.example to Scripts/project.env and fill local values."
  exit 1
fi

set -a
. "$SCRIPT_DIR/project.env"
set +a

"$SCRIPT_DIR/xcodegen/generate.sh"
