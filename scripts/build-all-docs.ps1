# ITT API Documentation Build Script (PowerShell Version)
# This script generates ReDoc documentation for all API services on Windows.

$ErrorActionPreference = "Stop"

$RootDir = Get-Location
$OpenapiDir = Join-Path $RootDir "openapi"
$RedocDir = Join-Path $RootDir "doc"

if (-not (Test-Path $RedocDir)) {
    New-Item -ItemType Directory -Path $RedocDir | Out-Null
}

$HeadLinks = @"
<link rel="icon" type="image/x-icon" href="./public/favicon.ico">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;700&display=swap" rel="stylesheet">
"@

$NavHtml = @"
<style>
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
        font-family: 'Inter', sans-serif;
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
    .menu-content, [data-role='redoc-menu'] {
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
<div class='itt-top-header'>
    <a href='index.html' class='back-btn' title='Back to Portal'>
        <span class='arrow'>&larr;</span>
        <span class='text'>Back to Portal</span>
    </a>
</div>
"@

function Inject-NavButtons {
    param([string]$FileName)
    $FilePath = Join-Path $RedocDir $FileName
    if (Test-Path $FilePath) {
        $Content = [System.IO.File]::ReadAllText($FilePath)
        
        # Inject Head Links
        if ($Content -match "</head>") {
            $Content = $Content -replace "</head>", ($HeadLinks + "`n</head>")
        }

        # Inject Nav Buttons (Robust regex for </body> with leading whitespace)
        $Pattern = '(?i)\s*</body>'
        $Replacement = $NavHtml + "`n  </body>"
        $NewContent = [regex]::Replace($Content, $Pattern, $Replacement)
        
        [System.IO.File]::WriteAllText($FilePath, $NewContent, [System.Text.Encoding]::UTF8)
        Write-Host "   -> Navigation and Fonts injected into $FileName" -ForegroundColor Cyan
    }
}

function Build-Service {
    param([string]$InputFile, [string]$OutputName)
    Write-Host "--- Building $OutputName ---" -ForegroundColor Yellow
    $InputPath = Join-Path $OpenapiDir $InputFile
    $OutputPath = Join-Path $RedocDir $OutputName
    
    # Run npx command
    npx --yes @redocly/cli build-docs $InputPath -o $OutputPath --title "ITT $OutputName API"
    
    Inject-NavButtons -FileName $OutputName
}

Write-Host "Starting documentation generation..." -ForegroundColor Green

# Run generation for each YAML file
Build-Service "openapi.yaml" "openapi.html"
Build-Service "Flight.yaml" "generated-flight.html"
Build-Service "Hotel.yaml" "generated-hotel.html"
Build-Service "eSim.yaml" "esim.html"
Build-Service "Activity.yaml" "activity.html"
Build-Service "Visa.yaml" "visa.html"
Build-Service "Train.yaml" "train.html"
Build-Service "Transfer.yaml" "transfer.html"
Build-Service "Tour-Packege.yaml" "tour-package.html"

Write-Host "All documentation generated successfully!" -ForegroundColor Green
Write-Host "View it at: $RedocDir\index.html"
