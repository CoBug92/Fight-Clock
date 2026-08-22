#!/bin/sh

set -e

export PATH="/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"
CONFIG_PATH="$SCRIPT_DIR/.swiftlint.yml"

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "warning: SwiftLint not installed, download it from https://github.com/realm/SwiftLint"
    exit 1
fi

cd "$PROJECT_ROOT"
swiftlint lint \
    --config "$CONFIG_PATH" \
    --no-cache \
    Main \
    LiveActivity
