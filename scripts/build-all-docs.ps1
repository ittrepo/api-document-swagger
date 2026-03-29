# ITT API Documentation Build Script (PowerShell Version)
# This script generates ReDoc documentation for all 8 API services on Windows.

$ErrorActionPreference = "Stop"

$RootDir = Get-Location
$OpenapiDir = Join-Path $RootDir "openapi"
$RedocDir = Join-Path $RootDir "redoc"

if (-not (Test-Path $RedocDir)) {
    New-Item -ItemType Directory -Path $RedocDir | Out-Null
}

$NavHtml = '<div style="position: fixed; bottom: 30px; left: 30px; z-index: 9999; display: flex; gap: 10px;">
    <a href="index.html" style="background: #0f172a; color: #38bdf8; width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.4); border: 1px solid rgba(56, 189, 248, 0.2); text-decoration: none; font-size: 20px; transition: all 0.3s ease; box-sizing: border-box;" onmouseover="this.style.transform=''scale(1.1)'';this.style.background=''#1e293b''" onmouseout="this.style.transform=''scale(1)'';this.style.background=''#0f172a''" title="Go to Home Portal">🏠</a>
    <button onclick="window.history.back()" style="background: #0f172a; color: #38bdf8; width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.4); border: 1px solid rgba(56, 189, 248, 0.2); cursor: pointer; font-size: 20px; transition: all 0.3s ease; box-sizing: border-box;" onmouseover="this.style.transform=''scale(1.1)'';this.style.background=''#1e293b''" onmouseout="this.style.transform=''scale(1)'';this.style.background=''#0f172a''" title="Go Back">🔙</button>
</div>'

function Inject-NavButtons {
    param([string]$FileName)
    $FilePath = Join-Path $RedocDir $FileName
    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
        $NewContent = $Content -replace '</body>', "$NavHtml</body>"
        $NewContent | Set-Content $FilePath
        Write-Host "   🧭 Navigation buttons injected." -ForegroundColor Cyan
    }
}

function Build-Service {
    param([string]$InputFile, [string]$OutputName)
    Write-Host "📦 Building $OutputName..." -ForegroundColor Yellow
    $InputPath = Join-Path $OpenapiDir $InputFile
    $OutputPath = Join-Path $RedocDir $OutputName
    
    # Run npx command
    npx --yes @redocly/cli build-docs $InputPath -o $OutputPath --title "ITT $OutputName API"
    
    Inject-NavButtons -FileName $OutputName
}

Write-Host "🚀 Generating documentation... This may take a moment." -ForegroundColor Green

# Run generation for each YAML file
Build-Service "openapi.yaml" "openapi.html"
Build-Service "flight.yaml" "generated-flight.html"
Build-Service "hotel.yaml" "generated-hotel.html"
Build-Service "esim.yaml" "esim.html"
Build-Service "Visa.yaml" "visa.html"
Build-Service "Train.yaml" "train.html"
Build-Service "Transfer.yaml" "transfer.html"
Build-Service "Tour-Packege.yaml" "tour-package.html"

Write-Host "`n✅ All documentation generated successfully in the /redoc directory!" -ForegroundColor Green
Write-Host "`n🌐 To view the documentation, open this file in your browser:"
Write-Host "   $RedocDir\index.html"
Write-Host "`n🚀 Pro tip: Right-click 'redoc\index.html' and select 'Open in Default Browser'."
