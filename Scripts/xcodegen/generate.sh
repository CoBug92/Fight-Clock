#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
cd "$ROOT"

"$ROOT/Scripts/swiftgen/generate.sh"

command -v xcodegen >/dev/null 2>&1 || {
  echo "error: XcodeGen is required (https://github.com/yonaskolb/XcodeGen)." >&2
  exit 1
}

xcodegen generate --spec "$ROOT/Scripts/xcodegen/project.yml" --project "$ROOT" --project-root "$ROOT"
