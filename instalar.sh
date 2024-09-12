#!/usr/bin/env bash
# Desenvolvido por William Santos
# contato: thespation@gmail.com ou https://github.com/thespation

# Cores
CIAN="\033[0;36m"
NORM="\033[0m"
VERD="\033[0;32m"
VERM="\033[1;31m"

# Alias
SI="sudo apt install -y"
SA="sudo apt"
GG="git clone"
GITH="https://raw.githubusercontent.com/thespation/dpux_bspwm/main/scripts/"
i3pf="$HOME/.config"
i3t="/tmp/i3wm"
data_atual=$(date +"%Y%m%d%H%M%S")

# Listas de pacotes e URLs
declare -a PACOTES=(
    i3 xorg i3status lightdm i3lock xsettingsd xfce4-power-manager network-manager sudo
    suckless-tools rofi alacritty nm-tray nitrogen feh lxappearance picom thunar tumbler
    thunar-archive-plugin thunar-volman dh-autoreconf make maim python3-pip git curl
    python3-i3ipc xdg-user-dirs htop neofetch viewnior cargo xclip yad catfish baobab
    meld xarchiver geany alsa-utils pulseaudio pavucontrol pulsemixer gcc make libx11-dev
    libxtst-dev pkg-config sysstat ranger vim hsetroot sysvinit-utils psmisc ncal
)

# Função: Atualizar sistema
atualizar_sistema() {
    echo -e "${CIAN}[ ] Atualizar sistema${NORM}"
    ${SA} update && ${SA} upgrade -y && ${SA} dist-upgrade -y
    echo -e "${VERD}[*] Sistema atualizado${NORM}"
    instalar_programas
}

# Função: Instalar programas
instalar_programas() {
    echo -e "\n${CIAN}[ ] Instalando programas${NORM}"
    ${SI} "${PACOTES[@]}"
    echo -e "${VERD}[*] Aplicativos instalados${NORM}"
    xdg-user-dirs-update

    if [[ ! -d "/tmp/i3blocks" ]]; then
    echo -e "\n${CIAN}[ ] Compilar e instalar i3blocks${NORM}"
        cd /tmp && ${GG} https://github.com/vivien/i3blocks
        cd i3blocks && chmod +x autogen.sh && ./autogen.sh && ./configure && make && sudo make install
    fi
    echo -e "\n${VERD}[*] i3blocks instalada${NORM}"

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
    
    ksuperkey
}

# Função: Habilitar tecla Super para abrir menu
ksuperkey() {
    echo -e "\n${CIAN}[ ] Habilitar tecla Super${NORM}"
    if [[ ! -d "/tmp/ksuperkey" ]]; then
        cd /tmp && ${GG} https://github.com/hanschen/ksuperkey.git
        cd ksuperkey && make && sudo make install
    fi
    echo -e "${VERD}[*] Tecla Super habilitada${NORM}"

    curl -s ${GITH}temas.sh | bash
    curl -s ${GITH}icones.sh | bash
    
    lightdm
}

# Função: Configurar LightDM
lightdm() {
    lightdm_conf="/etc/lightdm/lightdm.conf"
    ldm_conf="/etc/lightdm/lightdm-gtk-greeter.conf"

    [[ -f "${lightdm_conf}" ]] && {
        echo -e "\n${CIAN}[ ] Habilitar último login usado${NORM}"
        sudo cp ${lightdm_conf} ${lightdm_conf}_BKP_${data_atual}
        sudo sed -i 's/^#greeter-hide-users=false/greeter-hide-users=false/' ${lightdm_conf}
        echo -e "${VERD}[*] Usuário habilitado na tela de login${NORM}"
    }

    [[ -f ${ldm_conf} ]] && {
        echo -e "\n${CIAN}[ ] Criando backup de lightdm.conf${NORM}"
        sudo mv ${ldm_conf} ${ldm_conf}_BKP_${data_atual}
        sudo cp -rf ${i3t}/config/lightdm-gtk-greeter.conf ${ldm_conf}
        sudo cp -rf ${i3t}/i3/wallpapers/mono.png /usr/share/images/desktop-base/wallpaper.jpg
        echo -e "${VERD}[*] lightdm configurado${NORM}"
    }

    xinit
}

# Função: Habilitar inicialização do i3
xinit() {
    [[ ! -f ~/.xinitrc ]] && cp /etc/X11/xinit/xinitrc ~/.xinitrc
    sed -i 's/^exec xterm -geometry 80x66+0+0 -name login/#exec xterm -geometry 80x66+0+0 -name login/' ~/.xinitrc
    echo "exec i3" >> ~/.xinitrc
    echo -e "${VERD}[*] i3 habilitado${NORM}"
    personalizacao
}

# Função: Copiar personalizações
personalizacao() {
    echo -e "\n${CIAN}[ ] Copiar personalizações${NORM}"
    [[ ! -d "${i3t}" ]] && cd /tmp && ${GG} https://github.com/thespation/i3wm
    
    [[ -d "${i3pf}/i3" ]] && mv ${i3pf}/i3 ${i3pf}/i3_BKP_${data_atual}
    mkdir -p ${i3pf}/i3 && cp -rf ${i3t}/i3/* ${i3pf}/i3 && chmod +x ${i3pf}/i3/* -R
    cp -rf ${i3t}/fonts $HOME/.local/share

    echo -e "\n${CIAN}[ ] Atualizar fontes${NORM}"
    fc-cache -f -v && i3 reload
    echo -e "${VERD}[*] Fontes do sistema atualizadas${NORM}"

    [[ -f $HOME/.gtkrc-2.0 ]] && mv $HOME/.gtkrc-2.0 $HOME/.gtkrc-2.0_BKP_${data_atual}
    cp -rf ${i3t}/config/.gtkrc-2.0 $HOME/.gtkrc-2.0

    mkdir -p ${i3pf}/gtk-3.0
    [[ -f ${i3pf}/gtk-3.0/settings.ini ]] && mv ${i3pf}/gtk-3.0/settings.ini ${i3pf}/gtk-3.0/settings.ini_BKP_${data_atual}
    cp -rf ${i3t}/config/settings.ini ${i3pf}/gtk-3.0/settings.ini

    echo -e "${VERD}[*] Configurações copiadas${NORM}"
}

# Verifica se está usando Debian ou derivado
clear
if [[ -f "/etc/debian_version" ]]; then
    echo -e "${CIAN}[i] Script ${VERM}PESSOAL${CIAN} para instalação do i3wm no Debian 12"
    echo -e "${CIAN}[!] Instalação começará em ${VERM}10 segundos${CIAN}, para cancelar pressione: \"${VERM}Ctrl+c\"${NORM}\n"
    sleep 10
    atualizar_sistema
else
    echo -e "${VERM}[!] Esse script PESSOAL foi desenvolvido para rodar no Debian e seus derivados.${NORM}"
fi
