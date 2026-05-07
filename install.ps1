param(
    [switch]$Full,
    [switch]$WithAlacritty,
    [switch]$WithFonts,
    [string]$NvimRepo = "https://github.com/Hilvyy/nvim-config.git",
    [string]$NvimBranch = "stable"
)

$ErrorActionPreference = "Stop"

function Install-WithWinget {
    param(
        [string]$Id,
        [string]$Name
    )

    Write-Host "Instalando $Name..."
    winget install --id $Id -e --accept-package-agreements --accept-source-agreements
}

function Add-ToUserPath {
    param([string]$PathToAdd)

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($currentPath -notlike "*$PathToAdd*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$PathToAdd", "User")
        Write-Host "Agregado al PATH: $PathToAdd"
    }
}

function Install-NetcoreDbg {
    $targetDir = "$env:LOCALAPPDATA\netcoredbg"
    $exePath = "$targetDir\netcoredbg\netcoredbg.exe"
    $zipPath = "$env:TEMP\netcoredbg.zip"
    $url = "https://github.com/Samsung/netcoredbg/releases/latest/download/netcoredbg-win64.zip"

    if (Test-Path $exePath) {
        Write-Host "netcoredbg ya está instalado."
        Add-ToUserPath "$targetDir\netcoredbg"
        return
    }

    Write-Host "Descargando netcoredbg..."
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    Invoke-WebRequest $url -OutFile $zipPath
    Expand-Archive $zipPath -DestinationPath $targetDir -Force
    Remove-Item $zipPath -Force

    Add-ToUserPath "$targetDir\netcoredbg"
    Write-Host "netcoredbg instalado."
}

function Install-IosevkaNerdFont {
    Write-Host "Instalando Iosevka Nerd Font..."

    $fontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $zipPath = "$env:TEMP\Iosevka.zip"
    $extractPath = "$env:TEMP\IosevkaFont"
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"

    New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null

    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }

    Invoke-WebRequest $url -OutFile $zipPath
    Expand-Archive $zipPath -DestinationPath $extractPath -Force

    Get-ChildItem $extractPath -Filter "*.ttf" -Recurse | ForEach-Object {
        Copy-Item $_.FullName $fontsDir -Force
    }

    Remove-Item $zipPath -Force
    Remove-Item $extractPath -Recurse -Force

    Write-Host "Iosevka Nerd Font instalada."
    Write-Host "Puede que tengás que cerrar sesión o reiniciar la terminal."
}

function Install-AlacrittyConfig {
    $source = Join-Path $PSScriptRoot "configs\alacritty"
    $target = "$env:APPDATA\alacritty"

    if ($WithAlacritty -and (Test-Path $source)) {
        Write-Host "Copiando configuración de Alacritty..."
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        Copy-Item "$source\*" $target -Recurse -Force
    }
}

Write-Host "=== HILVIM Installer - Windows ==="

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget no está instalado. Instalá App Installer desde Microsoft Store."
}

Install-WithWinget "Git.Git" "Git"
Install-WithWinget "Neovim.Neovim" "Neovim"
Install-WithWinget "OpenJS.NodeJS.LTS" "Node.js LTS"
Install-WithWinget "BurntSushi.ripgrep.MSVC" "ripgrep"
Install-WithWinget "sharkdp.fd" "fd"
Install-WithWinget "Kitware.CMake" "CMake"
Install-WithWinget "LLVM.LLVM" "LLVM / clang"
Install-WithWinget "Zig.Zig" "Zig"

if ($Full) {
    Install-WithWinget "Python.Python.3.13" "Python"
    Install-WithWinget "Microsoft.DotNet.SDK.9" ".NET SDK"
    Install-WithWinget "EclipseAdoptium.Temurin.21.JDK" "Java JDK 21"
    Install-NetcoreDbg
}

if ($WithAlacritty) {
    Install-WithWinget "Alacritty.Alacritty" "Alacritty"
}

if ($WithFonts) {
    Install-IosevkaNerdFont
}

Install-AlacrittyConfig

$nvimPath = "$env:LOCALAPPDATA\nvim"

if (Test-Path $nvimPath) {
    $backup = "$env:LOCALAPPDATA\nvim.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Host "Ya existe config de Neovim. Creando backup en $backup"
    Move-Item $nvimPath $backup
}

Write-Host "Clonando configuración de Neovim..."
git clone -b $NvimBranch $NvimRepo $nvimPath

Write-Host ""
Write-Host "HILVIM instalado correctamente."
Write-Host "Cerrá y abrí la terminal otra vez."
Write-Host "Luego ejecutá: nvim"
