#!/usr/bin/env sh
# This script generates ReDoc documentation for all 8 API services.
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENAPI_DIR="$ROOT_DIR/openapi"
REDOC_DIR="$ROOT_DIR/doc"

mkdir -p "$REDOC_DIR"

# List of files to process
echo "🚀 Generating documentation... This may take a moment."

# Function to inject Home and Back buttons into generated HTML
inject_nav_buttons() {
    local file="$REDOC_DIR/$1"
    
    local head_links='<link rel="icon" type="image/x-icon" href="./public/favicon.ico">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;700&display=swap" rel="stylesheet">'

    local nav_html='<style>
    .itt-top-header {
        position: fixed;
        top: 0;
        left: 0;
        width: 260px;
        height: 60px;
        background: rgba(15, 23, 42, 0.9);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        display: flex;
        align-items: center;
        padding: 0 20px;
        z-index: 10000;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        box-sizing: border-box;
    }
    .back-btn {
        color: #f8fafc;
        text-decoration: none;
        font-family: '\''Inter'\'', sans-serif;
        font-weight: 600;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.3s ease;
        background: rgba(255, 255, 255, 0.05);
        padding: 6px 12px;
        border-radius: 6px;
        border: 1px solid rgba(255, 255, 255, 0.1);
    }
    .back-btn:hover {
        background: rgba(255, 255, 255, 0.1);
        transform: translateX(-3px);
        border-color: #38bdf8;
        color: #38bdf8;
    }
    .back-btn .arrow {
        font-size: 16px;
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
        # Inject Head Links
        sed -i.bak "s|</head>|$head_links</head>|g" "$file"
        # Inject Nav Buttons
        sed -i.bak "s|[[:space:]]*</body>|$nav_html</body>|g" "$file"
        rm -f "$file.bak"
        echo "   🧭 Navigation and Fonts injected into $1"
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
build_service "activity.yaml" "activity.html"
build_service "Visa.yaml" "visa.html"
build_service "Train.yaml" "train.html"
build_service "Transfer.yaml" "transfer.html"
build_service "Tour-Packege.yaml" "tour-package.html"

echo "✅ All documentation generated successfully in the /doc directory!"
echo ""
echo "🌐 To view the documentation, open this file in your browser:"
echo "   $REDOC_DIR/index.html"
echo ""
echo "🚀 Pro tip: If you are using VS Code, right-click 'doc/index.html' and select 'Open in Default Browser'."
