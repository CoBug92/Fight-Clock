#!/bin/sh
set -eu

export PATH="$PATH:/opt/homebrew/bin"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

command -v swiftgen >/dev/null 2>&1 || {
  echo "error: SwiftGen is required to generate resource symbols" >&2
  exit 1
}

swiftgen config run --config "$SCRIPT_DIR/swiftgen.yml"
