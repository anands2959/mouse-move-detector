# Mouse Speed Detector Installer Builder
# Developer: Anand Kumar Sharma
# Portfolio: www.anandsharma.online

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Mouse Speed Detector Installer Builder" -ForegroundColor Yellow
Write-Host "With Beautiful SVG Graphics" -ForegroundColor Magenta
Write-Host "Developer: Anand Kumar Sharma" -ForegroundColor Green
Write-Host "Portfolio: www.anandsharma.online" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command($command) {
    try {
        Get-Command $command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Check if NSIS is installed
if (-not (Test-Command "makensis")) {
    Write-Host "ERROR: NSIS (Nullsoft Scriptable Install System) is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install NSIS:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://nsis.sourceforge.io/Download" -ForegroundColor White
    Write-Host "2. Install NSIS" -ForegroundColor White
    Write-Host "3. Add NSIS installation directory to your PATH environment variable" -ForegroundColor White
    Write-Host "   (Usually: C:\Program Files (x86)\NSIS)" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternatively, you can install via Chocolatey:" -ForegroundColor Yellow
    Write-Host "choco install nsis" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check for SVG graphics and convert if needed
Write-Host "Checking for custom graphics..." -ForegroundColor Yellow
if ((Test-Path "logo.svg") -and (Test-Path "icon.svg") -and (Test-Path "welcome.svg")) {
    Write-Host "[SUCCESS] SVG graphics found" -ForegroundColor Green
    
    # Check if converted files exist and are newer than SVG files
    $needsConversion = $false
    
    if (-not (Test-Path "icon.ico")) {
        $needsConversion = $true
    } elseif ((Get-Item "icon.svg").LastWriteTime -gt (Get-Item "icon.ico").LastWriteTime) {
        $needsConversion = $true
    }
    
    if (-not (Test-Path "welcome.bmp")) {
        $needsConversion = $true
    } elseif ((Get-Item "welcome.svg").LastWriteTime -gt (Get-Item "welcome.bmp").LastWriteTime) {
        $needsConversion = $true
    }
    
    if ($needsConversion) {
        Write-Host "Converting SVG graphics to installer formats..." -ForegroundColor Cyan
        try {
            & .\convert-graphics.ps1
            Write-Host "[SUCCESS] Graphics converted successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "[WARNING] Graphics conversion failed, continuing with defaults" -ForegroundColor Yellow
            Write-Host "Run: .\convert-graphics.ps1 manually for custom graphics" -ForegroundColor White
        }
    } else {
        Write-Host "[SUCCESS] Graphics are up to date" -ForegroundColor Green
    }
} else {
    Write-Host "[INFO] Using default graphics (SVG files not found)" -ForegroundColor Blue
}
Write-Host ""

# Build the Rust project first
Write-Host "Building Rust project in release mode..." -ForegroundColor Yellow
try {
    cargo build --release
    if ($LASTEXITCODE -ne 0) {
        throw "Cargo build failed"
    }
    Write-Host "[SUCCESS] Rust project built successfully" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to build Rust project" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if the executable exists
if (-not (Test-Path "target\release\mouse-speed-detector.exe")) {
    Write-Host "ERROR: mouse-speed-detector.exe not found in target\release\" -ForegroundColor Red
    Write-Host "Make sure the Rust project builds successfully" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Create the installer
Write-Host ""
Write-Host "Building installer..." -ForegroundColor Yellow
try {
    makensis installer.nsi
    if ($LASTEXITCODE -ne 0) {
        throw "NSIS compilation failed"
    }
    Write-Host "[SUCCESS] Installer built successfully" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to build installer" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "SUCCESS! Installer created successfully" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installer file: " -NoNewline
Write-Host "MouseSpeedDetectorInstaller.exe" -ForegroundColor Yellow
Write-Host ""
Write-Host "The installer includes:" -ForegroundColor White
Write-Host "[+] Mouse Speed Detector application" -ForegroundColor Green
Write-Host "[+] Start Menu shortcuts" -ForegroundColor Green
Write-Host "[+] Desktop shortcut" -ForegroundColor Green
Write-Host "[+] Uninstaller" -ForegroundColor Green
Write-Host "[+] Registry entries" -ForegroundColor Green
Write-Host "[+] Developer information and portfolio link" -ForegroundColor Green
Write-Host ""
Write-Host "You can now distribute MouseSpeedDetectorInstaller.exe" -ForegroundColor Cyan
Write-Host ""

# Check installer file size
if (Test-Path "MouseSpeedDetectorInstaller.exe") {
    $fileSize = (Get-Item "MouseSpeedDetectorInstaller.exe").Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "Installer size: $fileSizeMB MB" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"