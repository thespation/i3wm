#!/usr/bin/env bash
# Desenvolvido por William Santos
# Contato: thespation@gmail.com | https://github.com/thespation
# Descrição: Script para instalar e configurar o i3wm no Debian 12 e derivados
# Data: 2025

# --- Configurações ---
# Cores
CIAN="\033[0;36m"
NORM="\033[0m"
VERD="\033[0;32m"
VERM="\033[1;31m"

# Comandos
SI="sudo apt install -y"
SA="sudo apt"
GG="git clone"
GITH="https://raw.githubusercontent.com/thespation/dpux_bspwm/main/scripts/"

# Diretórios
I3PF="$HOME/.config"
I3T="/tmp/i3wm"
FONTS_DIR="$HOME/.local/share/fonts"

# Arquivos de configuração
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"
LDM_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"
WALLPAPER="/usr/share/images/desktop-base/wallpaper.jpg"

# Outras variáveis
DATA_ATUAL=$(date +"%Y%m%d%H%M%S")
LOG_FILE="$HOME/LogI3wm${DATA_ATUAL}.txt"
RELOAD="i3 reload"

# Lista de pacotes a instalar
PACOTES=(
    i3 xorg i3status lightdm i3lock xsettingsd xfce4-power-manager network-manager sudo
    suckless-tools rofi alacritty nm-tray nitrogen feh lxappearance picom thunar tumbler
    thunar-archive-plugin thunar-volman dh-autoreconf make maim python3-pip git curl arandr
    python3-i3ipc xdg-user-dirs htop neofetch viewnior cargo xclip yad catfish baobab
    meld xarchiver geany alsa-utils pulseaudio pavucontrol pulsemixer gcc make libx11-dev
    libxtst-dev pkg-config sysstat ranger vim hsetroot sysvinit-utils psmisc ncal
)

# --- Funções de Utilidade ---
# Função para log e saída no terminal
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Função para verificar se um comando foi bem-sucedido
check_status() {
    if [ $? -eq 0 ]; then
        log "${VERD}[*] $1${NORM}"
    else
        log "${VERM}[!] Falha: $2${NORM}"
        exit 1
    fi
}

# Função para verificar se diretório existe
check_dir() {
    [ -d "$1" ] || mkdir -p "$1"
}

# Função para limpar arquivos temporários
limpar_temporarios() {
    log "${CIAN}[-] Limpando arquivos temporários${NORM}"
    rm -rf "$I3T" /tmp/i3blocks /tmp/ksuperkey
    check_status "Arquivos temporários removidos" "Falha ao limpar temporários"
}

# --- Funções Principais ---
# Função: Verificar pré-requisitos
verificar_requisitos() {
    log "${CIAN}[i] Verificando pré-requisitos${NORM}"

    # Verificar se é Debian ou derivado
    if ! command -v lsb_release >/dev/null 2>&1 || ! lsb_release -is | grep -E "Debian|Ubuntu" >/dev/null; then
        log "${VERM}[!] Este script suporta apenas Debian e derivados.${NORM}"
        exit 1
    fi

    # Verificar conexão com a internet
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        log "${VERM}[!] Sem conexão com a internet. Verifique sua rede.${NORM}"
        exit 1
    fi

    # Verificar sudo
    if ! command -v sudo >/dev/null 2>&1; then
        log "${VERM}[!] sudo não encontrado. Instale-o primeiro.${NORM}"
        exit 1
    fi

    log "${VERD}[*] Pré-requisitos verificados${NORM}"
}

# Função: Confirmar execução
confirmar_execucao() {
    log "${CIAN}[i] Script PESSOAL para instalação do i3wm no Debian 12"
    read -p "${CIAN}[?] Deseja continuar? (s/n): ${NORM}" resposta
    if [[ ! "$resposta" =~ ^[sS]$ ]]; then
        log "${VERM}[!] Instalação cancelada pelo usuário${NORM}"
        exit 0
    fi
}

# Função: Atualizar sistema
atualizar_sistema() {
    log "${CIAN}[-] Atualizando sistema${NORM}"
    sudo apt update
    check_status "Repositórios atualizados" "Falha ao atualizar repositórios"
    sudo apt upgrade -y
    check_status "Sistema atualizado" "Falha ao atualizar sistema"
    instalar_programas
}

# Função: Instalar programas
instalar_programas() {
    log "${CIAN}[-] Instalando programas${NORM}"

    # Filtrar pacotes já instalados
    PACOTES_NECESSARIOS=()
    for pkg in "${PACOTES[@]}"; do
        if ! dpkg -l "$pkg" >/dev/null 2>&1; then
            PACOTES_NECESSARIOS+=("$pkg")
        fi
    done

    if [ ${#PACOTES_NECESSARIOS[@]} -gt 0 ]; then
        ${SI} "${PACOTES_NECESSARIOS[@]}"
        check_status "Aplicativos instalados" "Falha ao instalar pacotes"
    else
        log "${VERD}[*] Todos os pacotes já estão instalados${NORM}"
    fi

    xdg-user-dirs-update
    check_status "Diretórios de usuário atualizados" "Falha ao atualizar diretórios"

    instalar_i3blocks
}

# Função: Instalar i3blocks
instalar_i3blocks() {
    log "${CIAN}[-] Instalando i3blocks${NORM}"
    if ! command -v i3blocks >/dev/null 2>&1; then
        check_dir "/tmp/i3blocks"
        cd /tmp && ${GG} https://github.com/vivien/i3blocks
        cd i3blocks && chmod +x autogen.sh && ./autogen.sh && ./configure && make && sudo make install
        check_status "i3blocks instalado" "Falha ao instalar i3blocks"
        rm -rf /tmp/i3blocks
    else
        log "${VERD}[*] i3blocks já instalado${NORM}"
    fi

    instalar_ohmybash
}

# Função: Instalar oh-my-bash
instalar_ohmybash() {
    log "${CIAN}[-] Instalando oh-my-bash${NORM}"
    if [ ! -d "$HOME/.oh-my-bash" ]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
        check_status "oh-my-bash instalado" "Falha ao instalar oh-my-bash"
    else
        log "${VERD}[*] oh-my-bash já instalado${NORM}"
    fi

    instalar_ksuperkey
}

# Função: Habilitar tecla Super com ksuperkey
instalar_ksuperkey() {
    log "${CIAN}[-] Habilitando tecla Super${NORM}"
    if ! command -v ksuperkey >/dev/null 2>&1; then
        check_dir "/tmp/ksuperkey"
        cd /tmp && ${GG} https://github.com/hanschen/ksuperkey.git
        cd ksuperkey && make && sudo make install
        check_status "ksuperkey instalado" "Falha ao instalar ksuperkey"
        rm -rf /tmp/ksuperkey
    else
        log "${VERD}[*] ksuperkey já instalado${NORM}"
    fi

    baixar_scripts_remotos
}

# Função: Baixar e executar scripts remotos
baixar_scripts_remotos() {
    log "${CIAN}[-] Baixando scripts remotos${NORM}"
    for script in temas.sh icones.sh; do
        if curl -s "${GITH}${script}" | bash; then
            check_status "$script executado" "Falha ao executar $script"
        else
            log "${VERM}[!] Falha ao baixar $script${NORM}"
            exit 1
        fi
    done

    configurar_lightdm
}

# Função: Configurar LightDM
configurar_lightdm() {
    log "${CIAN}[-] Configurando LightDM${NORM}"

    # Backup do lightdm.conf
    if [ -f "$LIGHTDM_CONF" ]; then
        sudo cp "$LIGHTDM_CONF" "${LIGHTDM_CONF}_BKP_${DATA_ATUAL}"
        check_status "Backup de lightdm.conf criado" "Falha ao criar backup"
        sudo sed -i 's/^#greeter-hide-users=false/greeter-hide-users=false/' "$LIGHTDM_CONF"
        check_status "Usuário habilitado na tela de login" "Falha ao configurar lightdm.conf"
    fi

    # Configurar greeter
    if [ -f "$LDM_CONF" ]; then
        sudo mv "$LDM_CONF" "${LDM_CONF}_BKP_${DATA_ATUAL}"
        check_status "Backup de lightdm-gtk-greeter.conf criado" "Falha ao criar backup"
    fi

    check_dir "$I3T"
    sudo cp -rf "${I3T}/config/lightdm-gtk-greeter.conf" "$LDM_CONF"
    check_status "Greeter copiado" "Falha ao copiar greeter"
    sudo cp "${I3T}/i3/wallpapers/mono.png" "$WALLPAPER"
    check_status "Papel de parede configurado" "Falha ao configurar papel de parede"

    configurar_xinit
}

# Função: Habilitar inicialização do i3
configurar_xinit() {
    log "${CIAN}[-] Configurando inicialização do i3${NORM}"
    if [ ! -f ~/.xinitrc ]; then
        cp /etc/X11/xinit/xinitrc ~/.xinitrc
        check_status "xinitrc copiado" "Falha ao copiar xinitrc"
    fi

    sed -i 's/^exec xterm -geometry 80x66+0+0 -name login/#exec xterm -geometry 80x66+0+0 -name login/' ~/.xinitrc
    echo "exec i3" >> ~/.xinitrc
    check_status "i3 habilitado no xinitrc" "Falha ao configurar xinitrc"

    personalizacao
}

# Função: Copiar personalizações
personalizacao() {
    log "${CIAN}[-] Aplicando personalizações${NORM}"

    # Clonar repositório de configurações, se necessário
    check_dir "$I3T"
    if [ ! -d "$I3T" ]; then
        cd /tmp && ${GG} https://github.com/thespation/i3wm
        check_status "Repositório i3wm clonado" "Falha ao clonar repositório"
    fi

    # Backup de configurações existentes
    if [ -d "${I3PF}/i3" ]; then
        mv "${I3PF}/i3" "${I3PF}/i3_BKP_${DATA_ATUAL}"
        check_status "Backup de i3 criado" "Falha ao criar backup"
    fi

    mkdir -p "${I3PF}/i3" && cp -rf "${I3T}/i3/"* "${I3PF}/i3" && chmod +x "${I3PF}/i3/"* -R
    check_status "Configurações do i3 copiadas" "Falha ao copiar configurações"

    check_dir "$FONTS_DIR"
    cp -rf "${I3T}/fonts"/* "$FONTS_DIR"
    fc-cache -f -v
    check_status "Fontes atualizadas" "Falha ao atualizar fontes"

    # Configurações GTK
    if [ -f "$HOME/.gtkrc-2.0" ]; then
        mv "$HOME/.gtkrc-2.0" "$HOME/.gtkrc-2.0_BKP_${DATA_ATUAL}"
        check_status "Backup de gtkrc-2.0 criado" "Falha ao criar backup"
    fi
    cp -rf "${I3T}/config/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
    check_status "gtkrc-2.0 configurado" "Falha ao configurar gtkrc-2.0"

    check_dir "${I3PF}/gtk-3.0"
    if [ -f "${I3PF}/gtk-3.0/settings.ini" ]; then
        mv "${I3PF}/gtk-3.0/settings.ini" "${I3PF}/gtk-3.0/settings.ini_BKP_${DATA_ATUAL}"
        check_status "Backup de settings.ini criado" "Falha ao criar backup"
    fi
    cp -rf "${I3T}/config/settings.ini" "${I3PF}/gtk-3.0/settings.ini"
    check_status "settings.ini configurado" "Falha ao configurar settings.ini"

    # Recarregar i3 apenas se estiver ativo
    if pgrep i3 >/dev/null; then
        $RELOAD
        check_status "i3 recarregado" "Falha ao recarregar i3"
    fi

    log "${CIAN}[i] Configurações aplicadas. Log salvo em $LOG_FILE${NORM}"
}

# --- Execução Principal ---
clear
verificar_requisitos
confirmar_execucao
atualizar_sistema
limpar_temporarios
log "${CIAN}[i] Instalação concluída. Log salvo em $LOG_FILE${NORM}"
