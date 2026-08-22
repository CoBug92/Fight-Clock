#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
  echo "Missing scripts/.env. Copy scripts/.env.example to scripts/.env and fill local values."
  exit 1
fi

set -a
. "$SCRIPT_DIR/.env"
set +a

mkdir -p "$PROJECT_DIR/Main/Resources/Generated"
"$SCRIPT_DIR/swiftgen/swiftgen.sh"
"$SCRIPT_DIR/xcodegen/xcodegen.sh"
