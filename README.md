# HILVIM

HILVIM es un entorno de desarrollo basado en Neovim + LazyVim que instala automáticamente herramientas comunes para desarrollo moderno.

Incluye:

* Neovim latest
* LazyVim
* Node.js
* ripgrep
* fd
* clang
* cmake
* Zig
* netcoredbg (.NET DAP)
* Alacritty (opcional)

---

# Requisitos

## Windows

* Windows 10/11
* PowerShell
* `winget` instalado

## Linux

* Ubuntu / Arch / Fedora
* Bash
* `curl`
* acceso sudo

---

# Instalación en Windows

## 1. Clonar el repositorio

```powershell
git clone https://github.com/Hilvyy/hilvim.git
cd hilvim
```

---

## 2. Ejecutar el instalador

Instalación completa:

```powershell
.\install.ps1 -Full -WithAlacritty `
  -NvimRepo "https://github.com/Hilvyy/nvim-config.git" `
  -NvimBranch "stable"
```

Instalación mínima:

```powershell
.\install.ps1 `
  -NvimRepo "https://github.com/Hilvyy/nvim-config.git"
```

---

## 3. Reiniciar terminal

Cerrar y volver a abrir PowerShell o Windows Terminal.

---

## 4. Abrir Neovim

```powershell
nvim
```

La primera vez LazyVim instalará plugins automáticamente.

---

# Instalación en Linux

## 1. Clonar el repositorio

```bash
git clone https://github.com/Hilvyy/hilvim.git
cd hilvim
```

---

## 2. Dar permisos

```bash
chmod +x install.sh
```

---

## 3. Ejecutar el instalador

Instalación completa:

```bash
./install.sh --full --with-alacritty \
  --repo "https://github.com/Hilvyy/nvim-config.git" \
  --branch "stable"
```

Instalación mínima:

```bash
./install.sh \
  --repo "https://github.com/Hilvyy/nvim-config.git"
```

---

## 4. Reiniciar terminal

```bash
source ~/.bashrc
```

O cerrar y volver a abrir la terminal.

---

## 5. Verificar instalación

```bash
nvim --version
```

Debe mostrar:

```txt
NVIM v0.11.x
```

---

## 6. Abrir Neovim

```bash
nvim
```

La primera vez LazyVim instalará plugins automáticamente.

---

# Actualizar instalación

## Actualizar configuración de Neovim

```bash
git -C ~/.config/nvim pull origin stable
```

---

## Actualizar plugins

Dentro de Neovim:

```vim
:Lazy sync
:MasonUpdate
```

---

## Actualizar HILVIM

```bash
cd ~/hilvim
git pull
```

---

# .NET Debugging (DAP)

HILVIM instala automáticamente:

```txt
netcoredbg
```

Verificar:

```bash
netcoredbg --version
```

---

## Debuggear aplicación .NET

1. Compilar proyecto:

```bash
dotnet build
```

2. Abrir proyecto:

```bash
nvim .
```

3. Iniciar debugging:

```txt
F5
```

4. Seleccionar:

```txt
Launch
```

5. Elegir el `.dll` generado.

---

# Flujo recomendado

```txt
Hilvyy/nvim-config (dev)
        ↓
stable branch
        ↓
Hilvyy/hilvim
        ↓
instalaciones físicas
```

---

# Recomendaciones

## Linux

* Se recomienda usar la versión latest oficial de Neovim.
* El installer ya evita la versión vieja de `apt`.

## Windows

* Se recomienda Windows Terminal o Alacritty.
* Reiniciar terminal después de instalar.

---

# Solución de problemas

## LazyVim pide Neovim >= 0.11

Verificar:

```bash
nvim --version
```

Si aparece una versión vieja, reiniciar terminal.

---

## `fd` no existe en Ubuntu

Ubuntu instala:

```txt
fdfind
```

El installer crea automáticamente alias `fd`.

---

## Error con `netcoredbg`

Verificar:

```bash
which netcoredbg
netcoredbg --version
```

---

## Error de Copilot

Copilot puede deshabilitarse en Linux/VM si no se utiliza.

---

# Próximamente

* `update.sh`
* `doctor.sh`
* instalación automática de Nerd Fonts
* soporte Termux/Android
* configuración portable tipo VSCode
