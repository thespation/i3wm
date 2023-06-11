#!/usr/bin/env bash
# Desenvolvido pelo William Santos
# contato: thespation@gmail.com ou https://github.com/thespation

# Cores (tabela de cores: https://gist.github.com/avelino/3188137)
CIAN="\033[0;36m"	#Deixa a saída na cor ciano     
NORM="\033[0m"		#Volta para a cor padrão        
VERD="\033[0;32m"	#Deixa a saída na cor verde
VERM="\033[1;31m"	#Deixa a saída na cor vermelho

## Alias
SI="sudo apt install -y"		#Comando para instalar novos pacotes
SA="sudo apt"				#Usado para atualizar sistema
data_atual=$(date +"%Y%m%d%H%M%S")	#Define a data e hora atual
lightdm="/etc/lightdm/lightdm.conf"	#Endereço completo do arquivo de configuração
GITH="https://raw.githubusercontent.com/thespation/dpux_bspwm/main/scripts/" #Endereço do script (tema e ícone)
data_atual=$(date +"%Y%m%d%H%M%S")	#Define a data e hora 
GG="git clone"

#--Função: Atualizar espelhos--#
declare -f _atualizar.sistema
function _atualizar.sistema(){
        echo -e "${CIAN}[ ] Atualizar sistema${NORM}"
            ${SA} update && ${SA} upgrade -y && ${SA} dist-upgrade -y && #Atualiza sistema
        echo -e "${VERD}[*] Sistema atualizado${NORM}"
        _instalar.programas #Chama a função     
}

#--Função: Instalar programas--#
declare -f _instalar.programas
function _instalar.programas(){
        echo -e "\n${CIAN}[ ] Instalar os programas necessários${NORM}"
            ${SI} \
                i3 xorg i3status lightdm i3lock \
                xsettingsd xfce4-power-manager network-manager sudo \
                dmenu rofi alacritty nm-tray \
                nitrogen feh lxappearance picom \
                thunar tumbler thunar-archive-plugin thunar-volman \
                dh-autoreconf make maim python3-pip git curl \
                xdg-user-dirs htop neofetch viewnior cargo xclip \
                catfish baobab meld xarchiver geany \
                gcc make libx11-dev libxtst-dev pkg-config sysstat \
                ranger vim hsetroot sysvinit-utils psmisc ncal
            xdg-user-dirs-update #Atualiza as pastas de usuário
            #Compilar i3blocks
            if [[ ! -d "/tmp/i3blocks" ]]; then # Verifica existencia da pasta /tmp/i3blocks
                #apt cache search dh-autoreconf
                cd /tmp && ${GG} https://github.com/vivien/i3blocks
                cd i3blocks; chmod +x autogen.sh
                ./autogen.sh; ./configure
                make; sudo make install
            fi
            echo -e "${VERD}[*] Aplicativos necessários instalados${NORM}"
            curl -s ${GITH}temas.sh | bash
            curl -s ${GITH}icones.sh | bash
         _ksuperkey #Chama a função
}

#--Função: Adicionar função de abrir menu (rofi) com tecla super (Ksuperkey)--#
declare -f _ksuperkey
function _ksuperkey(){
        if [[ ! -d "/tmp/ksuperkey" ]]; then # Verifica existencia da pasta /tmp/ksuperkey
            echo -e "\n${CIAN}[ ] Habilitar tecla Super para abrir menu" ${NORM}
                cd /tmp && ${GG} https://github.com/hanschen/ksuperkey.git &&
                cd ksuperkey
                make && sudo make install
	fi
        echo -e "${VERD}[*] Tecla Super habilitada com sucesso" ${NORM}
        _lightdm #Chama a função  
}

#--Função: Deixar usuário visível no login do LightDM--#
declare -f _lightdm
function _lightdm(){
    #Alias locais
    lightdm="/etc/lightdm/lightdm.conf" #Local do arquivo original
            
    if [ -f "${lightdm}" ]; then #Verifica a existência do arquivo de configuração
        echo -e "\n${CIAN}[ ] Criando backup do arquivo 'lightdm.conf"${NORM}
            sudo cp ${lightdm} ${lightdm}_BKP_${data_atual} &&
        echo -e "${VERD}[*] Backup criado com sucesso"
            sudo sed -i 's/^#greeter-hide-users=false/greeter-hide-users=false/g' ${lightdm} #Descomenta a linha
        echo -e "${VERD}[*] Arquivo lightdm.conf modificado"${NORM}
    fi      
    _xinit #Chama a função
}

#--Função: Habilitar inicialização i3 no arquivo ~/.xinitrc --#
declare -f _xinit
    function _xinit(){
        echo -e "\n${CIAN}[ ] Habilitar inicialização do i3${NORM}"
        if [ ! -f ~/.xinitrc ]; then #Verifica a existência do arquivo de configuração
            cp /etc/X11/xinit/xinitrc ~/.xinitrc
        fi
        sed -i 's/^exec xterm -geometry 80x66+0+0 -name login/#exec xterm -geometry 80x66+0+0 -name login/' ~/.xinitrc
            echo "exec i3" >> ~/.xinitrc
        echo -e "${VERD}[*] i3 habilitado${NORM}"
        _personalizacao #Chama a função
}

#--Função: Copiar personalizações--#
declare -f _personalizacao
function _personalizacao(){
    #Alias local
    i3pf="~/.config/i3/"
    i3t="/tmp/i3wm"
        if [[ ! -d "${i3t}" ]]; then # Verifica existencia da pasta /tmp/i3wm
            echo -e "${CIAN}[ ] Baixando configurações personalizadas ${NORM}"
            cd  /tmp && ${GG} https://github.com/thespation/i3wm
        fi
            if [[ -d "${i3pf}" ]]; then # Verifica existencia da pasta i3 no perfil do usuário
                mv ${i3pf} ${i3pf}_BKP_${data_atual}
            fi
            echo -e "${CIAN}[ ] Copiando configurações para pasta correta ${NORM}"
            mkdir -p ${i3pf} && cp -rf ${i3t}/i3* ${i3pf} && chmod +x ${i3pf}* -R
	    cp -rf /tmp/i3wm/fonts ~/.local/share #Copia as fontes necessárias
            echo -e "${VERD}[*] Configurações copiadas ${NORM}"
}


#Vefifica se está usando Debian ou derivado
	clear
    if [ -f "/etc/debian_version" ]; then #Verifica a existencia do arquivo "debian_version" 
        echo -e "\n${CIAN}[i] Script ${VERM}PESSOAL${CIAN} para instalação do i3wm na base Debian"
        echo -e "[?] Prosseguir? (digite '${VERD}s${CIAN}' ou '${VERD}sim${CIAN}')${NORM}"
            read resposta
            if [[ ($resposta = "s" ) || ($resposta = "sim") || ($resposta = "S") || ($resposta = "SIM") ]]; then #Verifica resposta
            _atualizar.sistema #Chama a função
            else
                echo -e "${VERM}[!] Instalação cancelada, não foi escolhida a opção correta para prosseguir.${NORM}"
            fi
    else
        echo -e "${VERM}[!] Esse script PESSOAL foi desenvolvido para rodar no Debian e seus derivados.${NORM}"
fi
