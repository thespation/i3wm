#!/usr/bin/env bash
# Desenvolvido por William Santos
# Contato: thespation@gmail.com | https://github.com/thespation
# Descrição: Script para instalar e configurar o i3wm no Debian 12 e derivados

# --- Configurações ---
CIAN="\033[0;36m"
NORM="\033[0m"
VERD="\033[0;32m"
VERM="\033[1;31m"

SI="sudo apt install -y"
SA="sudo apt"
GG="git clone"
GITH="https://raw.githubusercontent.com/thespation/dpux_bspwm/main/scripts/"

I3PF="$HOME/.config"
I3T="/tmp/i3wm"
DATA_ATUAL=$(date +"%Y%m%d%H%M%S")
LOG_FILE="$HOME/LogI3wm${DATA_ATUAL}.txt"
RELOAD="i3 reload"

PACOTES=(
    i3 xorg i3status lightdm i3lock xsettingsd xfce4-power-manager network-manager sudo
    # ... (demais pacotes)
)

# --- Funções de Utilidade ---
log() { echo -e "$1" | tee -a "$LOG_FILE"; }
check_status() { [ $? -eq 0 ] && log "${VERD}[*] $1${NORM}" || { log "${VERM}[!] Falha: $2${NORM}"; exit 1; }; }
check_dir() { [ -d "$1" ] || mkdir -p "$1"; }

# --- Funções Principais ---
verificar_requisitos() {
    log "${CIAN}[i] Verificando pré-requisitos${NORM}"
    command -v lsb_release >/dev/null 2>&1 && lsb_release -is | grep -E "Debian|Ubuntu" >/dev/null || { log "${VERM}[!] Apenas Debian e derivados são suportados${NORM}"; exit 1; }
    ping -c 1 google.com >/dev/null 2>&1 || { log "${VERM}[!] Sem conexão com a internet${NORM}"; exit 1; }
    command -v sudo >/dev/null 2>&1 || { log "${VERM}[!] sudo não encontrado${NORM}"; exit 1; }
    log "${VERD}[*] Pré-requisitos verificados${NORM}"
}

atualizar_sistema() {
    log "${CIAN}[-] Atualizando sistema${NORM}"
    sudo apt update && sudo apt upgrade -y
    check_status "Sistema atualizado" "Falha ao atualizar sistema"
    instalar_programas
}

# ... (outras funções revisadas)

# --- Execução ---
clear
verificar_requisitos
confirmar_execucao
atualizar_sistema
limpar_temporarios
log "${CIAN}[i] Instalação concluída. Log salvo em $LOG_FILE${NORM}"
