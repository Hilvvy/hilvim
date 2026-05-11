#!/usr/bin/env bash
set -e

FULL=false
WITH_ALACRITTY=false
WITH_FONTS=false
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
  --with-fonts)
    WITH_FONTS=true
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

add_local_bin_to_shell() {
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"

  if [ -f "$HOME/.bashrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
  fi

  if [ -f "$HOME/.zshrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.zshrc"
  fi
}

install_apt() {
  sudo apt update
  sudo apt install -y git curl unzip tar nodejs npm ripgrep fd-find \
    build-essential cmake clang make fontconfig

  sudo apt install -y zig || true

  if [ "$FULL" = true ]; then
    sudo apt install -y python3 python3-pip python3-venv default-jdk || true
    sudo apt install -y dotnet-sdk-9.0 || sudo apt install -y dotnet-sdk-8.0 || true
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo apt install -y alacritty || true
  fi
}

install_pacman() {
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm git curl unzip tar nodejs npm ripgrep fd \
    base-devel cmake clang make zig fontconfig

  if [ "$FULL" = true ]; then
    sudo pacman -S --noconfirm python python-pip jdk-openjdk dotnet-sdk || true
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo pacman -S --noconfirm alacritty || true
  fi
}

install_dnf() {
  sudo dnf install -y git curl unzip tar nodejs npm ripgrep fd-find \
    gcc gcc-c++ make cmake clang fontconfig

  sudo dnf install -y zig || true

  if [ "$FULL" = true ]; then
    sudo dnf install -y python3 python3-pip java-21-openjdk-devel dotnet-sdk-9.0 || true
  fi

  if [ "$WITH_ALACRITTY" = true ]; then
    sudo dnf install -y alacritty || true
  fi
}

fix_fd_on_ubuntu() {
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    echo "Alias fd creado desde fdfind."
  fi
}

install_neovim_latest() {
  echo "Instalando Neovim latest..."

  local archive="nvim-linux-x86_64.tar.gz"
  local url="https://github.com/neovim/neovim/releases/latest/download/$archive"
  local target="$HOME/.local/share/nvim-linux-x86_64"

  mkdir -p "$HOME/.local/share" "$HOME/.local/bin"
  rm -rf "$target"
  curl -L -o "/tmp/$archive" "$url"
  tar xzf "/tmp/$archive" -C "$HOME/.local/share"
  rm -f "/tmp/$archive"

  ln -sf "$target/bin/nvim" "$HOME/.local/bin/nvim"
  "$HOME/.local/bin/nvim" --version | head -n 1
}

install_netcoredbg() {
  echo "Instalando netcoredbg..."

  local target_base="$HOME/.local/share/netcoredbg"
  local target_bin="$HOME/.local/bin"
  local target_exe="$target_base/netcoredbg/netcoredbg"

  mkdir -p "$target_base" "$target_bin"

  if [ ! -f "$target_exe" ]; then
    local tmp_file
    tmp_file="$(mktemp /tmp/netcoredbg.XXXXXX.tar.gz)"

    curl -L -o "$tmp_file" \
      "https://github.com/Samsung/netcoredbg/releases/latest/download/netcoredbg-linux-amd64.tar.gz"

    tar -xzf "$tmp_file" -C "$target_base"
    rm "$tmp_file"
    chmod +x "$target_exe"
  fi

  ln -sf "$target_exe" "$target_bin/netcoredbg"
  "$target_bin/netcoredbg" --version | head -n 1 || true
}

install_iosevka_nerd_font() {
  echo "Instalando Iosevka Nerd Font..."

  local fonts_dir="$HOME/.local/share/fonts/IosevkaNerdFont"
  local zip_path="/tmp/Iosevka.zip"

  mkdir -p "$fonts_dir"

  curl -L -o "$zip_path" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"

  unzip -o "$zip_path" -d "$fonts_dir"
  rm -f "$zip_path"

  fc-cache -fv >/dev/null || true

  echo "Iosevka Nerd Font instalada."
}

install_alacritty_config() {
  if [ "$WITH_ALACRITTY" = true ] && [ -d "./configs/alacritty" ]; then
    echo "Copiando configuración de Alacritty..."
    mkdir -p "$HOME/.config/alacritty"
    cp -r ./configs/alacritty/* "$HOME/.config/alacritty/"
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

if [ "$WITH_FONTS" = true ]; then
  install_iosevka_nerd_font
fi

install_alacritty_config

NVIM_PATH="$HOME/.config/nvim"

if [ -d "$NVIM_PATH" ]; then
  BACKUP="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
  echo "Ya existe config de Neovim. Creando backup en $BACKUP"
  mv "$NVIM_PATH" "$BACKUP"
fi

echo "Clonando configuración de Neovim..."
mkdir -p "$HOME/.config"
git clone -b "$NVIM_BRANCH" "$NVIM_REPO" "$NVIM_PATH"

echo ""
echo "HILVIM instalado correctamente."
echo "Ejecutá: source ~/.bashrc"
echo "Luego: nvim ."
