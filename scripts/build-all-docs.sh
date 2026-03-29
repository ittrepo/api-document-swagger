#!/usr/bin/env sh
# This script generates ReDoc documentation for all 8 API services.
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENAPI_DIR="$ROOT_DIR/openapi"
REDOC_DIR="$ROOT_DIR/redoc"

mkdir -p "$REDOC_DIR"

# List of files to process
echo "🚀 Generating documentation... This may take a moment."

# Function to build ReDoc
build_service() {
    local input_file="$1"
    local output_name="$2"
    echo "📦 Building $output_name..."
    npx --yes @redocly/cli build-docs "$OPENAPI_DIR/$input_file" -o "$REDOC_DIR/$output_name" --title "ITT $output_name API"
}

# Run generation for each YAML file
build_service "openapi.yaml" "openapi.html"
build_service "flight.yaml" "generated-flight.html"
build_service "hotel.yaml" "generated-hotel.html"
build_service "esim.yaml" "esim.html"
build_service "Visa.yaml" "visa.html"
build_service "Train.yaml" "train.html"
build_service "Transfer.yaml" "transfer.html"
build_service "Tour-Packege.yaml" "tour-package.html"

echo "✅ All documentation generated successfully in the /redoc directory!"
echo ""
echo "🌐 To view the documentation, open this file in your browser:"
echo "   $REDOC_DIR/index.html"
echo ""
echo "🚀 Pro tip: If you are using VS Code, right-click 'redoc/index.html' and select 'Open in Default Browser'."
