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
    local nav_html='<style>
    .itt-top-header {
        position: fixed;
        top: 0;
        left: 0;
        width: 260px;
        height: 60px;
        background: #ffffff;
        display: flex;
        align-items: center;
        padding: 0 20px;
        z-index: 10000;
        border-bottom: 1px solid #e2e8f0;
        box-sizing: border-box;
    }
    .back-btn {
        color: #334155;
        text-decoration: none;
        font-family: '\''Inter'\'', sans-serif;
        font-weight: 600;
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: 10px;
        transition: all 0.3s ease;
    }
    .back-btn:hover {
        transform: translateX(-5px);
        color: #0f172a;
    }
    .back-btn .arrow {
        font-size: 18px;
    }
    /* Only push the sidebar menu down */
    .menu-content, [data-role='\''redoc-menu'\''] {
        margin-top: 60px !important;
    }
    .menu-content {
        top: 60px !important;
        height: calc(100vh - 60px) !important;
    }
    @media (max-width: 768px) {
        .itt-top-header {
            width: 100%;
            padding: 0 16px;
        }
        .redoc-container {
            margin-top: 60px !important;
        }
    }
</style>
<div class='\''itt-top-header'\''>
    <a href='\''index.html'\'' class='\''back-btn'\'' title='\''Back to Portal'\''>
        <span class='\''arrow'\''>&larr;</span>
        <span class='\''text'\''>Back to Portal</span>
    </a>
</div>'
    
    # Use a temporary file for cross-platform compatibility
    if [ -f "$file" ]; then
        # More robust sed replacement that handles leading whitespace
        sed -i.bak "s|[[:space:]]*</body>|$nav_html</body>|g" "$file"
        rm -f "$file.bak"
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
