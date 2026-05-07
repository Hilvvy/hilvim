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
    git curl unzip tar nodejs npm ripgrep fd-find \
    build-essential cmake clang make

  if sudo apt-cache show zig >/dev/null 2>&1; then
    sudo apt install -y zig
  else
    echo "Zig no está disponible en apt. Se omite."
  fi

  if [ "$FULL" = true ]; then
    sudo apt install -y python3 python3-pip python3-venv default-jdk || true

    if sudo apt-cache show dotnet-sdk-9.0 >/dev/null 2>&1; then
      sudo apt install -y dotnet-sdk-9.0
    elif sudo apt-cache show dotnet-sdk-8.0 >/dev/null 2>&1; then
      sudo apt install -y dotnet-sdk-8.0
    else
      echo ".NET SDK no está disponible en apt por defecto. Se omite."
    fi
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo apt install -y alacritty || true
  fi
}

install_pacman() {
  sudo pacman -Syu --noconfirm

  sudo pacman -S --noconfirm \
    git curl unzip tar nodejs npm ripgrep fd \
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
    git curl unzip tar nodejs npm ripgrep fd-find \
    gcc gcc-c++ make cmake clang

  if sudo dnf list zig >/dev/null 2>&1; then
    sudo dnf install -y zig
  else
    echo "Zig no está disponible en dnf. Se omite."
  fi

  if [ "$FULL" = true ]; then
    sudo dnf install -y python3 python3-pip java-21-openjdk-devel dotnet-sdk-9.0 || true
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo dnf install -y alacritty || true
  fi
}

install_neovim_latest() {
  echo "Instalando Neovim latest..."

  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"

  local archive="nvim-linux-x86_64.tar.gz"
  local url="https://github.com/neovim/neovim/releases/latest/download/$archive"
  local target="$HOME/.local/share/nvim-linux-x86_64"

  rm -rf "$target"
  rm -f "/tmp/$archive"

  curl -L -o "/tmp/$archive" "$url"
  tar xzf "/tmp/$archive" -C "$HOME/.local/share"
  rm -f "/tmp/$archive"

  ln -sf "$target/bin/nvim" "$HOME/.local/bin/nvim"

  add_local_bin_to_shell

  echo "Neovim instalado en: $HOME/.local/bin/nvim"
  "$HOME/.local/bin/nvim" --version | head -n 1
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
  add_local_bin_to_shell

  echo "netcoredbg instalado."
  "$TARGET_BIN/netcoredbg" --version | head -n 1 || true
}

add_local_bin_to_shell() {
  mkdir -p "$HOME/.local/bin"

  if [ -f "$HOME/.bashrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
  fi

  if [ -f "$HOME/.zshrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.zshrc"
  fi

  export PATH="$HOME/.local/bin:$PATH"
}

fix_fd_on_ubuntu() {
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    add_local_bin_to_shell
    echo "Alias fd creado desde fdfind."
  fi
}

if command -v apt >/dev/null 2>&1; then
  install_apt
elif command -v pacman >/dev/null 2>&1; then
  install_pacman
elif command -v dnf >/dev/null 2>&1; then
  install_dnf
else
  echo "No reconozco el gestor de paquetes."
  exit 1
fi

add_local_bin_to_shell
fix_fd_on_ubuntu
install_neovim_latest

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
echo "Cerrá y abrí la terminal otra vez, o ejecutá:"
echo 'source ~/.bashrc'
echo ""
echo "Luego probá:"
echo "nvim --version"
echo "nvim ."
