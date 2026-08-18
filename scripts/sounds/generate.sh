#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
ruby "$ROOT/scripts/sounds/generate_placeholders.rb"

