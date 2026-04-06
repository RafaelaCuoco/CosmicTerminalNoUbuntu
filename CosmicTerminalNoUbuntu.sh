#!/bin/bash

###############################################################################
# CosmicTerminalNoUbuntu.sh
# Script para compilar, instalar e configurar o Cosmic Terminal como padrão
# no Ubuntu
###############################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Verificar se está rodando como root
if [ "$EUID" -eq 0 ]; then 
    log_error "Por favor, não execute este script como root. Use sudo quando necessário."
    exit 1
fi

# Verificar se é Ubuntu
if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
    log_error "Este script foi projetado para Ubuntu. Sistema detectado:"
    cat /etc/os-release 2>/dev/null | head -n 1
    exit 1
fi

# Verificar conexão com internet
if ! ping -c 1 -W 3 github.com &>/dev/null; then
    log_error "Sem conexão com a internet. Verifique sua conexão."
    exit 1
fi

###############################################################################
# VALIDAÇÃO: Verificar se o Cosmic Terminal já está instalado
###############################################################################
log_info "Verificando se o Cosmic Terminal já está instalado..."

# Verificar se o binário cosmic-term está disponível
if command -v cosmic-term &>/dev/null; then
    log_success "Cosmic Terminal já está instalado!"
    COSMIC_TERM_VERSION=$(cosmic-term --version 2>/dev/null || echo "versão desconhecida")
    log_info "Versão instalada: $COSMIC_TERM_VERSION"
    
    # Pular para a seção de configuração
    SKIP_INSTALL=true
    log_info "Aplicando configurações de atalhos e tema..."
else
    log_info "Cosmic Terminal não está instalado. Iniciando instalação..."
    SKIP_INSTALL=false
fi

###############################################################################
# PRÉ-REQUISITOS
###############################################################################
if [ "$SKIP_INSTALL" = false ]; then
    log_info "Verificando pré-requisitos..."

    # Atualizar lista de pacotes
    log_info "Atualizando lista de pacotes..."
    sudo apt update -y

    # Instalar dependências necessárias
    log_info "Instalando dependências de build..."
    sudo apt install -y \
        build-essential \
        cargo \
        librust-atk-dev \
        libcairo2-dev \
        libglib2.0-dev \
        libgtk-4-dev \
        libxkbcommon-dev \
        pkg-config \
        git \
        cmake \
        libssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libexpat1-dev

    # Verificar se o Rust está instalado
    if ! command -v rustc &>/dev/null; then
        log_info "Instalando Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Verificar versões
    log_info "Rust版本: $(rustc --version)"
    log_info "Cargo版本: $(cargo --version)"
fi

###############################################################################
# CLONAR REPOSITÓRIO
###############################################################################
if [ "$SKIP_INSTALL" = false ]; then
    COSMIC_SOURCE_DIR="$HOME/cosmic-term-source"
    
    if [ -d "$COSMIC_SOURCE_DIR/.git" ]; then
        log_info "Repositório já clonado. Atualizando..."
        cd "$COSMIC_SOURCE_DIR"
        git pull
    else
        log_info "Clonando repositório do Cosmic Terminal..."
        if [ -d "$COSMIC_SOURCE_DIR" ]; then
            rm -rf "$COSMIC_SOURCE_DIR"
        fi
        git clone https://github.com/pop-os/cosmic-term.git "$COSMIC_SOURCE_DIR"
        cd "$COSMIC_SOURCE_DIR"
    fi

    ###############################################################################
    # COMPILAÇÃO
    ###############################################################################
    log_info "Iniciando compilação do Cosmic Terminal..."
    
    # Garantir que temos as dependências do projeto
    cargo fetch
    
    # Build em modo release
    log_info "Executando build em modo release (isso pode demorar)..."
    cargo build --release

    ###############################################################################
    # INSTALAÇÃO
    ###############################################################################
    log_info "Instalando Cosmic Terminal..."
    
    # Criar diretório de instalação se não existir
    sudo mkdir -p /usr/local/bin
    
    # Copiar binário compilado
    sudo cp target/release/cosmic-term /usr/local/bin/
    sudo chmod +x /usr/local/bin/cosmic-term

    # Instalar arquivo .desktop se existir
    if [ -f "data/com.system76.CosmicTerm.desktop" ]; then
        sudo cp data/com.system76.CosmicTerm.desktop /usr/share/applications/
        log_info "Arquivo .desktop instalado em /usr/share/applications/"
    elif [ -f "com.system76.CosmicTerm.desktop" ]; then
        sudo cp com.system76.CosmicTerm.desktop /usr/share/applications/
        log_info "Arquivo .desktop instalado em /usr/share/applications/"
    fi

    # Instalar ícones se existirem
    if [ -d "data/icons" ]; then
        sudo cp -r data/icons /usr/share/icons/hicolor 2>/dev/null || true
    fi

    # Atualizar cache de ícones e desktop
    sudo update-desktop-database 2>/dev/null || true
    sudo gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true

    log_success "Cosmic Terminal compilado e instalado com sucesso!"
fi

###############################################################################
# CONFIGURAR ATALHOS: Ctrl+C e Ctrl+V
###############################################################################
log_info "Configurando atalhos Ctrl+C e Ctrl+V..."

SHORTCUTS_DIR="$HOME/.config/cosmic/com.system76.CosmicTerm.Shortcuts/v1"
SHORTCUTS_FILE="$SHORTCUTS_DIR/custom"

# Criar diretório se não existir
mkdir -p "$SHORTCUTS_DIR"

# Verificar se o arquivo de configuração já existe e contém as configurações
if [ -f "$SHORTCUTS_FILE" ] && grep -q "Copy.*Ctrl.*c" "$SHORTCUTS_FILE" 2>/dev/null; then
    log_success "Atalhos Ctrl+C e Ctrl+V já estão configurados!"
else
    log_info "Criando arquivo de configuração de atalhos..."
    
    # Backup do arquivo existente se houver
    if [ -f "$SHORTCUTS_FILE" ]; then
        cp "$SHORTCUTS_FILE" "${SHORTCUTS_FILE}.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backup criado: ${SHORTCUTS_FILE}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # Criar arquivo de configuração com Ctrl+C e Ctrl+V
    cat > "$SHORTCUTS_FILE" << 'EOF'
# Configuração personalizada de atalhos do Cosmic Terminal
# Ctrl+C para copiar, Ctrl+V para colar

[custom]

# Copiar com Ctrl+C (substitui Ctrl+Shift+C)
Copy = [
    { modifiers = ["Ctrl"], key = "c" }
]

# Colar com Ctrl+V (substitui Ctrl+Shift+V)
Paste = [
    { modifiers = ["Ctrl"], key = "v" }
]

# Copiar ou enviar SIGINT com Ctrl+Shift+C (mantém funcionalidade original)
CopyOrSigint = [
    { modifiers = ["Ctrl", "Shift"], key = "c" }
]

# Colar com Shift+Insert (mantém padrão Linux)
PastePrimary = [
    { modifiers = ["Shift"], key = "Insert" }
]
EOF
    
    log_success "Atalhos configurados: Ctrl+C (copiar) e Ctrl+V (colar)"
fi

###############################################################################
# CONFIGURAR TEMA DO COSMIC TERMINAL
###############################################################################
log_info "Configurando tema do Cosmic Terminal..."

TERM_THEME_DIR="$HOME/.config/cosmic/com.system76.CosmicTerm/v1"
TERM_THEME_FILE="$TERM_THEME_DIR/custom.toml"

# Criar diretório se não existir
mkdir -p "$TERM_THEME_DIR"

# Verificar se o tema já está configurado
if [ -f "$TERM_THEME_FILE" ] && grep -q "name.*Phosphor Green" "$TERM_THEME_FILE" 2>/dev/null; then
    log_success "Tema do Cosmic Terminal já está configurado!"
else
    log_info "Criando configuração de tema..."
    
    # Backup do arquivo existente se houver
    if [ -f "$TERM_THEME_FILE" ]; then
        cp "$TERM_THEME_FILE" "${TERM_THEME_FILE}.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backup criado: ${TERM_THEME_FILE}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # Criar arquivo de configuração de tema
    cat > "$TERM_THEME_FILE" << 'EOF'
# Configuração de tema personalizado do Cosmic Terminal
# Tema: Phosphor Green

name = "Phosphor Green"
colors = {
    background = "0a0a0a",
    foreground = "33ff33",
    cursor = "33ff33",
    palette = [
        "0a0a0a",  # black
        "33ff33",  # red
        "33ff66",  # green
        "33ff99",  # yellow
        "33ffcc",  # blue
        "33ffaa",  # magenta
        "33ffdd",  # cyan
        "33ffee",  # white
        "0f0f0f",  # bright black
        "66ff66",  # bright red
        "66ff99",  # bright green
        "99ffcc",  # bright yellow
        "66ffcc",  # bright blue
        "66ffdd",  # bright magenta
        "66ffee",  # bright cyan
        "99ffff",  # bright white
    ],
}

[colors.primary]
background = "0a0a0a"
foreground = "33ff33"

[colors.cursor]
text = "0a0a0a"
cursor = "33ff33"

[colors.normal]
black = "0a0a0a"
red = "33ff33"
green = "33ff66"
yellow = "33ff99"
blue = "33ffcc"
magenta = "33ffaa"
cyan = "33ffdd"
white = "33ffee"

[colors.bright]
black = "0f0f0f"
red = "66ff66"
green = "66ff99"
yellow = "99ffcc"
blue = "66ffcc"
magenta = "66ffdd"
cyan = "66ffee"
white = "99ffff"

[terminal]
font = "JetBrainsMono Nerd Font"
font_size = 12
opacity = 0.75
padding = 8
EOF
    
    log_success "Tema personalizado configurado!"
    log_info "  - Tema: Phosphor Green"
    log_info "  - Fonte: JetBrainsMono Nerd Font (tamanho 12)"
    log_info "  - Opacidade: 75%"
    log_info "  - Padding: 8px"
fi

###############################################################################
# CONFIGURAR COMO TERMINAL PADRÃO
###############################################################################
log_info "Configurando Cosmic Terminal como terminal padrão..."

# Método 1: gnome-default-applications-properties (se disponível)
if command -v xdg-settings &>/dev/null; then
    log_info "Configurando via xdg-settings..."
    xdg-settings set default-terminal-app cosmic-term.desktop 2>/dev/null || \
    xdg-settings set default-terminal-app com.system76.CosmicTerm.desktop 2>/dev/null || true
fi

# Método 2: Adicionar ao .bashrc como fallback
if ! grep -q "cosmic-term" ~/.bashrc 2>/dev/null; then
    log_info "Adicionando alias ao .bashrc..."
    echo "" >> ~/.bashrc
    echo "# Cosmic Terminal como terminal padrão" >> ~/.bashrc
    echo "alias terminal='cosmic-term'" >> ~/.bashrc
fi

# Método 3: Configurar mimeapps.list
MIMEAPPS_FILE="$HOME/.config/mimeapps.list"
mkdir -p "$HOME/.config"

if [ ! -f "$MIMEAPPS_FILE" ]; then
    echo "[Default Applications]" > "$MIMEAPPS_FILE"
fi

if ! grep -q "x-scheme-handler/terminal" "$MIMEAPPS_FILE" 2>/dev/null; then
    echo "x-scheme-handler/terminal=cosmic-term.desktop" >> "$MIMEAPPS_FILE"
fi

# Método 4: Criar script wrapper se necessário
if [ ! -f "/usr/local/bin/x-terminal-emulator" ]; then
    log_info "Criando link simbólico para x-terminal-emulator..."
    sudo ln -sf /usr/local/bin/cosmic-term /usr/local/bin/x-terminal-emulator
fi

###############################################################################
# VALIDAÇÃO FINAL
###############################################################################
log_info "Executando validação final..."

if command -v cosmic-term &>/dev/null; then
    log_success "✓ Cosmic Terminal está instalado e acessível"
    log_info "  Localização: $(which cosmic-term)"
    log_info "  Versão: $(cosmic-term --version 2>/dev/null || 'N/A')"
else
    log_error "✗ Falha na instalação - cosmic-term não encontrado no PATH"
    exit 1
fi

if grep -q "cosmic-term" ~/.bashrc 2>/dev/null; then
    log_success "✓ Alias configurado no .bashrc"
else
    log_warn "✗ Alias não encontrado no .bashrc"
fi

if [ -f "$MIMEAPPS_FILE" ] && grep -q "cosmic-term" "$MIMEAPPS_FILE" 2>/dev/null; then
    log_success "✓ Configuração MIME apps definida"
fi

if [ -f "$SHORTCUTS_FILE" ] && grep -q "Copy.*Ctrl.*c" "$SHORTCUTS_FILE" 2>/dev/null; then
    log_success "✓ Atalhos Ctrl+C e Ctrl+V configurados"
    log_info "  Arquivo: $SHORTCUTS_FILE"
else
    log_warn "✗ Atalhos não configurados"
fi

if [ -f "$TERM_THEME_FILE" ] && grep -q "name.*Phosphor Green" "$TERM_THEME_FILE" 2>/dev/null; then
    log_success "✓ Tema personalizado configurado"
    log_info "  Arquivo: $TERM_THEME_FILE"
else
    log_warn "✗ Tema não configurado"
fi

###############################################################################
# RESUMO
###############################################################################
echo ""
log_success "═══════════════════════════════════════════════════════"
log_success "  Cosmic Terminal instalado e configurado com sucesso!"
log_success "═══════════════════════════════════════════════════════"
echo ""
log_info "Para usar o Cosmic Terminal:"
echo "  - Execute: cosmic-term"
echo "  - Ou use o alias: terminal"
echo ""
log_info "Atalhos configurados:"
echo "  - Ctrl+C: Copiar"
echo "  - Ctrl+V: Colar"
echo "  - Ctrl+Shift+C: Copiar ou enviar SIGINT"
echo "  - Shift+Insert: Colar seleção primária"
echo ""
log_info "Tema configurado:"
echo "  - Tema: Phosphor Green"
echo "  - Fonte: JetBrainsMono Nerd Font (12px)"
echo "  - Opacidade: 75%"
echo "  - Padding: 8px"
echo ""
log_info "Para tornar efetivo as configurações:"
echo "  - Reinicie o terminal ou execute: source ~/.bashrc"
echo "  - Reinicie o Cosmic Terminal se já estiver aberto"
echo ""
log_warn "Nota: Se você estiver usando GNOME, pode precisar"
log_warn "configurar manualmente o terminal padrão nas"
log_warn "configurações do sistema."
echo ""

exit 0
