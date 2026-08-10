#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
ruby "$ROOT/Scripts/sounds/generate_placeholders.rb"

