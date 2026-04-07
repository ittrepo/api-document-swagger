# ITT API Documentation Build Script (PowerShell Version)
# This script generates ReDoc documentation for all 8 API services on Windows.

$ErrorActionPreference = "Stop"

$RootDir = Get-Location
$OpenapiDir = Join-Path $RootDir "openapi"
$RedocDir = Join-Path $RootDir "redoc"

if (-not (Test-Path $RedocDir)) {
    New-Item -ItemType Directory -Path $RedocDir | Out-Null
}

$NavHtml = "
<style>
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
        font-family: 'Inter', sans-serif;
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
</div>"

function Inject-NavButtons {
    param([string]$FileName)
    $FilePath = Join-Path $RedocDir $FileName
    if (Test-Path $FilePath) {
        $Content = [System.IO.File]::ReadAllText($FilePath)
        # Robust regex for </body> with leading whitespace
        $Pattern = '(?i)\s*</body>'
        $Replacement = $NavHtml + "`n  </body>"
        $NewContent = [regex]::Replace($Content, $Pattern, $Replacement)
        [System.IO.File]::WriteAllText($FilePath, $NewContent, [System.Text.Encoding]::UTF8)
        Write-Host "   -> Navigation buttons injected." -ForegroundColor Cyan
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
Build-Service "flight.yaml" "generated-flight.html"
Build-Service "hotel.yaml" "generated-hotel.html"
Build-Service "esim.yaml" "esim.html"
Build-Service "Visa.yaml" "visa.html"
Build-Service "Train.yaml" "train.html"
Build-Service "Transfer.yaml" "transfer.html"
Build-Service "Tour-Packege.yaml" "tour-package.html"

Write-Host "All documentation generated successfully!" -ForegroundColor Green
Write-Host "View it at: $RedocDir\index.html"
