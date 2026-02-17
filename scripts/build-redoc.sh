#!/usr/bin/env sh
set -euo pipefail
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INPUT="$ROOT_DIR/openapi/openapi.yaml"
OUTPUT_DIR="$ROOT_DIR/redoc"
mkdir -p "$OUTPUT_DIR"
npx --yes @redocly/cli build-docs "$INPUT" -o "$OUTPUT_DIR/generated-docs.html"