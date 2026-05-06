#!/usr/bin/env bash
set -e

FULL=false
WITH_ALACRITTY=false
NVIM_REPO="https://github.com/Hilvvy/nvim-config.git"
NVIM_BRANCH="stable"

while [[ $# -gt 0 ]]; do
  case "$1" in
  --full)
    FULL=true
    shift
    ;;
  --with-alacritty)
    WITH_ALACRITTY=true
    shift
    ;;
  --repo)
    NVIM_REPO="$2"
    shift 2
    ;;
  --branch)
    NVIM_BRANCH="$2"
    shift 2
    ;;
  *)
    echo "Argumento desconocido: $1"
    exit 1
    ;;
  esac
done

echo "=== HILVIM Installer - Linux ==="

install_apt() {
  sudo apt update

  sudo apt install -y \
    git curl unzip tar neovim nodejs npm ripgrep fd-find \
    build-essential cmake clang make

  if sudo apt-cache show zig >/dev/null 2>&1; then
    sudo apt install -y zig
  else
    echo "Zig no está disponible en apt para esta distro. Se omite."
  fi

  if [ "$FULL" = true ]; then
    sudo apt install -y python3 python3-pip python3-venv default-jdk || true

    if sudo apt-cache show dotnet-sdk-9.0 >/dev/null 2>&1; then
      sudo apt install -y dotnet-sdk-9.0
    elif sudo apt-cache show dotnet-sdk-8.0 >/dev/null 2>&1; then
      sudo apt install -y dotnet-sdk-8.0
    else
      echo ".NET SDK no está disponible en apt por defecto. Instalalo luego desde Microsoft si hace falta."
    fi
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo apt install -y alacritty || true
  fi
}

install_pacman() {
  sudo pacman -Syu --noconfirm

  sudo pacman -S --noconfirm \
    git curl unzip tar neovim nodejs npm ripgrep fd \
    base-devel cmake clang make zig

  if [ "$FULL" = true ]; then
    sudo pacman -S --noconfirm python python-pip jdk-openjdk dotnet-sdk || true
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo pacman -S --noconfirm alacritty || true
  fi
}

install_dnf() {
  sudo dnf install -y \
    git curl unzip tar neovim nodejs npm ripgrep fd-find \
    gcc gcc-c++ make cmake clang

  if sudo dnf list zig >/dev/null 2>&1; then
    sudo dnf install -y zig
  else
    echo "Zig no está disponible en dnf para esta distro. Se omite."
  fi

  if [ "$FULL" = true ]; then
    sudo dnf install -y python3 python3-pip java-21-openjdk-devel dotnet-sdk-9.0 || true
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo dnf install -y alacritty || true
  fi
}

install_netcoredbg() {
  TARGET_BASE="$HOME/.local/share/netcoredbg"
  TARGET_BIN="$HOME/.local/bin"
  TARGET_EXE="$TARGET_BASE/netcoredbg/netcoredbg"

  if [ -f "$TARGET_EXE" ]; then
    echo "netcoredbg ya está instalado."
  else
    echo "Descargando netcoredbg..."

    mkdir -p "$TARGET_BASE"
    mkdir -p "$TARGET_BIN"

    TMP_FILE="$(mktemp /tmp/netcoredbg.XXXXXX.tar.gz)"

    curl -L -o "$TMP_FILE" \
      "https://github.com/Samsung/netcoredbg/releases/latest/download/netcoredbg-linux-amd64.tar.gz"

    tar -xzf "$TMP_FILE" -C "$TARGET_BASE"
    rm "$TMP_FILE"

    chmod +x "$TARGET_EXE"
  fi

  ln -sf "$TARGET_EXE" "$TARGET_BIN/netcoredbg"

  if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    if [ -f "$HOME/.bashrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
    fi

    if [ -f "$HOME/.zshrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.zshrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.zshrc"
    fi
  fi

  echo "netcoredbg instalado."
}

if command -v apt >/dev/null 2>&1; then
  install_apt
elif command -v pacman >/dev/null 2>&1; then
  install_pacman
elif command -v dnf >/dev/null 2>&1; then
  install_dnf
else
  echo "No reconozco el gestor de paquetes. Instalá dependencias manualmente."
  exit 1
fi

if [ "$FULL" = true ]; then
  install_netcoredbg
fi

NVIM_PATH="$HOME/.config/nvim"

if [ -d "$NVIM_PATH" ]; then
  BACKUP="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
  echo "Ya existe config de Neovim. Creando backup en $BACKUP"
  mv "$NVIM_PATH" "$BACKUP"
fi

echo "Clonando configuración de Neovim..."
mkdir -p "$HOME/.config"
git clone -b "$NVIM_BRANCH" "$NVIM_REPO" "$NVIM_PATH"

if [ "$WITH_ALACRITTY" = true ] && [ -d "./configs/alacritty" ]; then
  mkdir -p "$HOME/.config/alacritty"
  cp -r ./configs/alacritty/* "$HOME/.config/alacritty/"
fi

echo ""
echo "HILVIM instalado correctamente."
echo "Cerrá y abrí la terminal otra vez."
echo "Luego ejecutá: nvim"
