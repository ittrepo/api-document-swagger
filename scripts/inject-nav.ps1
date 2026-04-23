# Inject navigation into a single HTML file
param([string]$FileName)

$RootDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$DocDir = Join-Path $RootDir "doc"
$FilePath = Join-Path $DocDir $FileName

if (-not (Test-Path $FilePath)) {
    Write-Host "File not found: $FilePath"
    exit 1
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

$Content = [System.IO.File]::ReadAllText($FilePath)

# Inject Head Links
if ($Content -match "</head>") {
    $Content = $Content -replace "</head>", ($HeadLinks + "`n</head>")
}

# Inject Nav Buttons
$Pattern = '(?i)\s*</body>'
$Replacement = $NavHtml + "`n  </body>"
$Content = [regex]::Replace($Content, $Pattern, $Replacement)

[System.IO.File]::WriteAllText($FilePath, $Content, [System.Text.Encoding]::UTF8)
Write-Host "Navigation injected into $FileName successfully!"
