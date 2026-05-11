# HILVIM

HILVIM es un entorno de desarrollo portable basado en Neovim + LazyVim.

Automatiza la instalación de:

* Neovim (última versión estable)
* LazyVim
* Git
* Node.js
* ripgrep
* fd
* Herramientas de compilación C/C++ (clang, make, cmake)
* Zig
* Python (opcional)
* .NET SDK (opcional)
* Java JDK (opcional)
* netcoredbg (depurador para .NET)
* Alacritty (opcional)
* Iosevka Nerd Font Mono (opcional)

El objetivo es ofrecer un entorno de desarrollo reproducible y portable para Windows y Linux, similar a un "VS Code portable", pero completamente basado en Neovim.

---

# Características

* Instaladores multiplataforma para Windows y Linux.
* Instalación automática de herramientas de desarrollo.
* Configuración automática de Neovim desde un repositorio Git.
* Instalación opcional de Alacritty con un `alacritty.toml` preconfigurado.
* Instalación opcional de Iosevka Nerd Font Mono.
* Instalación automática de `netcoredbg` para depuración de .NET.
* En Linux se instala la última versión oficial de Neovim, evitando versiones desactualizadas de los repositorios.

---

# Estructura del Repositorio

```text
hilvim/
├── install.ps1
├── install.sh
├── README.md
├── configs/
│   └── alacritty/
│       └── alacritty.toml
└── scripts/
```

---

# Requisitos

## Windows

* Windows 10 u 11
* PowerShell
* `winget`

## Linux

* Ubuntu, Arch Linux, Fedora o distribuciones compatibles
* Bash
* `curl`
* `sudo`

---

# Instalación

## Windows

### Clonar el repositorio

```powershell
git clone https://github.com/Hilvvy/hilvim.git
cd hilvim
```

### Instalación completa

```powershell
.\install.ps1 -Full -WithAlacritty -WithFonts
```

### Instalación mínima

```powershell
.\install.ps1
```

### Usando un repositorio de configuración personalizado

```powershell
.\install.ps1 -Full -WithAlacritty -WithFonts `
  -NvimRepo "https://github.com/Hilvvy/nvim-config.git" `
  -NvimBranch "stable"
```

---

## Linux

### Clonar el repositorio

```bash
git clone https://github.com/Hilvvy/hilvim.git
cd hilvim
```

### Dar permisos de ejecución

```bash
chmod +x install.sh
```

### Instalación completa

```bash
./install.sh --full --with-alacritty --with-fonts
```

### Instalación mínima

```bash
./install.sh
```

### Usando un repositorio de configuración personalizado

```bash
./install.sh --full --with-alacritty --with-fonts \
  --repo "https://github.com/Hilvvy/nvim-config.git" \
  --branch "stable"
```

---

# Flags Opcionales

## Windows

* `-Full` → Instala Python, .NET SDK, Java JDK y `netcoredbg`
* `-WithAlacritty` → Instala Alacritty y copia `alacritty.toml`
* `-WithFonts` → Instala Iosevka Nerd Font Mono

## Linux

* `--full` → Instala Python, .NET SDK, Java JDK y `netcoredbg`
* `--with-alacritty` → Instala Alacritty y copia `alacritty.toml`
* `--with-fonts` → Instala Iosevka Nerd Font Mono

---

# Primer Inicio

Después de la instalación:

```bash
nvim
```

En la primera ejecución, LazyVim instalará automáticamente todos los plugins.

---

# Configuración de Alacritty

Si se usa `--with-alacritty` o `-WithAlacritty`, el instalador copia:

```text
configs/alacritty/alacritty.toml
```

A:

### Linux

```text
~/.config/alacritty/alacritty.toml
```

### Windows

```text
%APPDATA%\\alacritty\\alacritty.toml
```

---

# Fuentes

Si se usa `--with-fonts` o `-WithFonts`, el instalador descarga e instala:

* Iosevka Nerd Font Mono

Configuración recomendada para Alacritty:

```toml
[font.normal]
family = "Iosevka Nerd Font Mono"
style = "Regular"
```

---

# Depuración de .NET

Cuando se utiliza la instalación completa, HILVIM instala `netcoredbg`.

Verificar la instalación:

```bash
netcoredbg --version
```

Para depurar un proyecto .NET:

```bash
dotnet build
nvim .
```

Luego presioná:

```text
F5
```

Y seleccioná `Launch`.

---

# Actualización

## Actualizar la configuración de Neovim

```bash
git -C ~/.config/nvim pull origin stable
```

## Actualizar plugins

Dentro de Neovim:

```vim
:Lazy sync
:MasonUpdate
```

## Actualizar el repositorio de HILVIM

```bash
cd ~/hilvim
git pull
```

## Actualizar paquetes del sistema (Linux)

```bash
sudo apt update && sudo apt upgrade -y
```

---

# Flujo de Trabajo Recomendado

```text
Hilvvy/nvim-config (desarrollo)
          ↓
      rama stable
          ↓
      Hilvvy/hilvim
          ↓
 Equipos instalados
```

1. Desarrollar y probar cambios en `Hilvvy/nvim-config`.
2. Fusionar los cambios probados a la rama `stable`.
3. HILVIM instala la rama `stable`.
4. Las instalaciones existentes se actualizan con `git pull`.

---

# Solución de Problemas

## LazyVim requiere Neovim >= 0.11

Verificar:

```bash
nvim --version
```

El instalador de Linux descarga automáticamente la última versión oficial de Neovim.

---

## El comando `fd` no existe en Ubuntu

Ubuntu instala `fdfind`. El instalador crea automáticamente un alias `fd`.

---

## netcoredbg no se encuentra

Verificar:

```bash
which netcoredbg
netcoredbg --version
```

---

## Errores de Copilot

Copilot puede deshabilitarse si no se utiliza.

---

# Próximas Características

* `update.sh`
* `update.ps1`
* `doctor.sh`
* `doctor.ps1`
* Soporte para Termux/Android
* Presets adicionales de terminal

---

# Licencia

MIT License.
