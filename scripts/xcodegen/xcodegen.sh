#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
SCRIPTS_DIR="$ROOT/scripts"
cd "$ROOT"

command -v xcodegen >/dev/null 2>&1 || {
  echo "error: XcodeGen is required (https://github.com/yonaskolb/XcodeGen)." >&2
  exit 1
}

if [ ! -f "$SCRIPTS_DIR/.env" ]; then
  echo "Missing scripts/.env. Copy scripts/.env.example to scripts/.env and fill local values."
  exit 1
fi

set -a
. "$SCRIPTS_DIR/.env"
set +a

xcodegen generate --spec "$ROOT/scripts/xcodegen/project.yml" --project "$ROOT" --project-root "$ROOT"
