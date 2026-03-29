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

# Function to inject Home and Back buttons into generated HTML
inject_nav_buttons() {
    local file="$REDOC_DIR/$1"
    local nav_html='<div style="position: fixed; bottom: 30px; left: 30px; z-index: 9999; display: flex; gap: 10px;">
    <a href="index.html" style="background: #0f172a; color: #38bdf8; width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.4); border: 1px solid rgba(56, 189, 248, 0.2); text-decoration: none; font-size: 20px; transition: all 0.3s ease; box-sizing: border-box;" onmouseover="this.style.transform=\'scale(1.1)\';this.style.background=\'#1e293b\'" onmouseout="this.style.transform=\'scale(1)\';this.style.background=\'#0f172a\'" title="Go to Home Portal">🏠</a>
    <button onclick="window.history.back()" style="background: #0f172a; color: #38bdf8; width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.4); border: 1px solid rgba(56, 189, 248, 0.2); cursor: pointer; font-size: 20px; transition: all 0.3s ease; box-sizing: border-box;" onmouseover="this.style.transform=\'scale(1.1)\';this.style.background=\'#1e293b\'" onmouseout="this.style.transform=\'scale(1)\';this.style.background=\'#0f172a\'" title="Go Back">🔙</button>
</div>'
    
    # Use a temporary file for cross-platform compatibility
    if [ -f "$file" ]; then
        sed "s|</body>|$nav_html</body>|g" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        echo "   🧭 Navigation buttons injected."
    fi
}

# Function to build ReDoc
build_service() {
    local input_file="$1"
    local output_name="$2"
    echo "📦 Building $output_name..."
    npx --yes @redocly/cli build-docs "$OPENAPI_DIR/$input_file" -o "$REDOC_DIR/$output_name" --title "ITT $output_name API"
    inject_nav_buttons "$output_name"
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
