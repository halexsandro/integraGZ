#!/bin/bash

# @Programa 
# 	@name: integraGZ.sh
#	@versao: 0.1
#	@Data 20 de Novembro de 2015
# 	
# 	@Direitos 
# 		@autor: Halexsando de Freitas Sales
#		@e-mail: halexsandro@gmail.com
#	@Licenca: GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 <http://www.gnu.org/licenses/lgpl.txt>
#	
#	@Objetivo:
#		Este script tem como objetivo realizar a completa instalação do 
#               serviço zabbix-server, zabbix-agent e zabbix-frontend
#
#
# Referências
# Para construção deste script, foram ustilizadas importantes informações contidas em:
# [manipulação do MySQL via prompt] - http://thobias.org/doc/shell_bd.html
# [pacotes zabbix] - https://www.zabbix.com/documentation/2.4/manual/installation/install_from_packages#debian_ubuntu

# -------------------------------------------------------------------
#
# Gustavo Soares <slot.mg@gmail.com>
#           * Modificado todas as chamadas de echo para whiptail e pv.
#           * Modificado diversas chamadas para bash4.
#           - Removido os scripts internos, agora devera ser feito download deles tb.
clear

[ ! -e /usr/bin/whiptail ] && { echo "POR FAVOR INSTALE O PACOTE whiptail PARA COMECAR."; exit 1; }

# VARIAVEIS
TITULO="INSTALADOR INTEGRAGZ.SH"
BANNER="http://www.pillares.net"
URLZABBIX="http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix"

# TELA INICIAL
whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
 Olá,                                                    
 Este script tem por objetivo realizar a instalação  dos 
 seguintes sistemas de forma automatizada:               
 - Zabbix 2.4.6.1 [http://zabbix.com]                    
 - GLPI 0.90 [http://glpi-project.com                    
 ------------------------------------------------------- 
 Fora os aplicativos citados, serão instalados recursos  
 adicionais que permitem a integração do Zabbix com GLPI 
 e alguns plugins úteis do GLPI de forma a economizar    
 tempo do Administrador.                                 
 -------------------------------------------------------
 integraGZ.sh | versão 0.1                               
 Desenvolvido por: Halexsandro de Freitas Sales          
 Contato: halexsandro@gmail.com                          
---------------------------------------------------------
                http://www.pillares.net                  
---------------------------------------------------------
" 0 0 0

# VERIFICAR SE O USUÁRIO É O ROOT
[ ${UID} != 0 ] && {
    whiptail --title "${TITULO}" \
             --backtitle "${BANNER}" \
             --msgbox "
 ERRO: Falta de acesso/privilégio                        
 É necessário acesso de Administrador do Sistema         
---------------------------------------------------------
                                                         
            Encerrarei este processo agora!              
                                                         
 Você precisa estar logado como root para executar este  
 script.                                                 
---------------------------------------------------------
" 0 0 0; exit 1; }

# DETECTAR A VERSÃO DO SISTEMA OPERACIONAL
[ $(lsb_release -c -s) != "jessie" ] && {
    whiptail --title "${TITULO}" \
             --backtitle "${BANNER}" \
             --msgbox "
        ERRO: Sistema Operacional não suportado          
---------------------------------------------------------
                                                         
            Encerrarei este processo agora!              
                                                         
 Este script foi desenvolvido para o Debian 8.           
                                                         
 Caso tenha alguma dúvida ou acredite que esta           
 informação esteja errada, favor entrar em contato!      
---------------------------------------------------------
" 0 0 0; exit 1; }

# DETECTANDO A ARQUITETURA DO SISTEMA
[ $(egrep -c ^i <(arch)) == "1" ] && arch="i386" 
[ $(egrep -c ^x <(arch)) == "1" ] && arch="amd64"
[ -z "${arch}" ] && {
    whiptail --title "${TITULO}" \
             --backtitle "${BANNER}" \
             --msgbox "
 ERRO: Arquitetura do Processador não suportada           
----------------------------------------------------------
                                                          
             Encerrarei este processo agora!              
                                                          
 Este script foi desenvolvido para as seguintes           
 arquiteturas:                                            
 - i386, i486, i586, i686 [32 bits]                       
 - x86_64 [64 bits]                                       
                                                          
 Caso tenha alguma dúvida ou acredite que esta informação 
 esteja errada, favor entrar em contato!                  
---------------------------------------------------------
" 0 0 0; exit 1; }

# INSTALANDO DEPENDÊNCIAS
whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --ok-button "SIM" \
         --cancel-button "NAO" \
         --yesno "
           Requisitos de sistema atendidos!              
----------------------------------------------------
                                                         
 Um dos programas instalados trata-se do MariaDB. Durante
 a instalação será solicitado uma senha para o usuário   
 administrativo do Banco de Dados.                       
 Também será solicitada uma senha para o usuário do banco
 de dados Zabbix. Estas senhas não precisam ser iguais   
 mas, serão necessárias para configurarmos o ambiente do 
 Zabbix pela interface WEB.                              
                                                         
 DESEJA CONTINUAR COM A INSTALACAO?                      
---------------------------------------------------------
" 0 0 0

[ $? == "1" ] && exit 1

# REALIZANDO CÓPIA DE SEGURANÇA DE SOURCES.LIST

[ -e /etc/apt/sources.list-ori ] && {
    whiptail --title "${TITULO}" \
             --backtitle "${BANNER}" \
             --ok-button "SIM" \
             --cancel-button "NAO" \
             --yesno "
         Script já executado neste computador!           
---------------------------------------------------------                                                         
 Aparentemente este script já foi executado neste        
 computador.                                             
 Portanto, não faremos backup novamente do arquivo       
 '/etc/apt/sources.list'.                                

DESEJA CONTINUAR COM A INSTALACAO?
---------------------------------------------------------
" 0 0 0 
    [ $? == "1" ] && exit 1
}

cp -f /etc/apt/sources.list{,.ori}

echo "deb http://ftp.br.debian.org/debian/ jessie main
deb-src http://ftp.br.debian.org/debian/ jessie main
deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main
deb http://ftp.br.debian.org/debian/ jessie-updates main
deb-src http://ftp.br.debian.org/debian/ jessie-updates main
deb http://ftp.de.debian.org/debian/ jessie main non-free" > /etc/apt/sources.list

# INSTALACAO DE PACOTES
whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --ok-button "SIM" \
         --cancel-button "NAO" \
         --yesno "
              Instalação de Pacotes                      
---------------------------------------------------------
                                                         
 Realizaremos agora a instalação de softwares que são    
 necessários para o correto funcionamento dos sistemas   
 Zabbix e GLPI. Dentre estes estão:                      
  - Banco de Dados MariaDB                               
  - Servidor HTTP Apache                                 
  - Suporte a linguagem PHP                              
  - Suporte ao protocolo SNMP                            

DESEJA CONTINUAR COM A INSTALACAO?
---------------------------------------------------------
" 0 0 0 

[ $? == "1" ] && exit 1

apt-get update
apt-get install mariadb-server apache2 apache2-mpm-prefork apache2-utils apache2.2-bin apache2.2-common php-soap php5 php5-cli php5-common php5-gd php5-mysql php5-xmlrpc libapache2-mod-php5 php5-imap php5-ldap snmp snmp-mibs-downloader fping ca-certificates ttf-dejavu-core libcurl3 librtmp1 dbconfig-common libdbi-perl libiksemel3 libodbc1 libopenipmi0 libssh2-1 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libonig2 libqdbm14 zip unzip bzip2 unrar-free pv dialog -y


# DOWNLOAD E INSTALAÇÃO DOS PACOTES ZABBIX

clear
whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
     Dependências resolvidas - Ambiente pronto!          
----------------------------------------------------
                                                         
 Tudo Certo! Seu servidor está pronto para receber os    
 sistemas Zabbix e GLPI.                                 
                                                         
 Procederemos agora com a instalação do Zabbix.          
---------------------------------------------------------
" 0 0 0 

#BAIXANDO E INSTALANDO OS PACOTES DO ZABBIX
mkdir -p /tmp/zabbix
cd /tmp/zabbix
wget ${URLZABBIX}/zabbix-agent_2.4.6-1+jessie_$arch.deb
wget ${URLZABBIX}/zabbix-get_2.4.6-1+jessie_$arch.deb
wget ${URLZABBIX}/zabbix-sender_2.4.6-1+jessie_$arch.deb
wget ${URLZABBIX}/zabbix-server-mysql_2.4.6-1+jessie_$arch.deb
wget ${URLZABBIX}/zabbix-frontend-php_2.4.6-1+jessie_all.deb

clear

whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
                Pacotes Baixados...                      
---------------------------------------------------------
                                                         
 Iniciando instalação do Zabbix.                         
                                                         
 Responda <SIM> a pergunta de configuração do banco      
 de dados do sistema.                                    
 A primeira senha solicitada é a do usuário Root do SGBD 
 MariaDB que você cadastrou anteriormente.               
 Na sequência, será solicitada uma senha para o usuário  
 zabbix que será criado no MariaDB                       
---------------------------------------------------------
" 0 0 0 

# INSTALANDO PACOTES
dpkg -iB *deb

# -------------------------------------------------------------------
# Adequando as variáveis do PHP para uso no Apache

clear

whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --radiolist "
          Configurando detalhes do Zabbix                
 Essa configuração é necessária para o Zabbix mas pode   
 ser alterada manualmente editando o seguinte arquivo:   
--------------------------------------------------------
       /etc/apache2/conf-enabled/zabbix.conf             
-------------------------------------------------------- " 0 0 0 \
        "Bahia" "Bahia" off \
        "Belem" "Belem" off \
        "Campo_Grande" "Campo Grande" off \
        "Fortaleza" "Fortaleza" off \
        "Maceio" "Maceio" off \
        "Manaus" "Manaus" off \
        "Noronha" "Noronha" off \
        "Porto_Velho" "Porto Velho" off \
        "Recife" "Recife" off \
        "Rio_Branco" "Rio Branco" off \
        "Sao_Paulo" "Sao Paulo" on 2> /tmp/timezone$$

Timezone=$(cat /tmp/timezone$$)


# Adequando PHP para o Zabbix
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/'$TimeZone'\n    php_value always_populate_raw_post_data -1/' /etc/apache2/conf-enabled/zabbix.conf

# Habilitando Execução de Scripts via ZabbixAgent
sed -i 's/# EnableRemoteCommands=0*/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf

# Reiniciando o serviço Zabbix e Apache

systemctl restart zabbix-server
systemctl restart zabbix-agent
systemctl restart apache2 

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Instalação do GLPI e do WEB Service

clear

whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
                   Instalação do GLPI                    
---------------------------------------------------------
                                                         
 O processo de instalação do Zabbix foi finalizado.      
 Procederemos agora com a instalação do GLPI e de alguns 
 plugins úteis:                                          
---------------------------------------------------------
 Plugins que serão Instalados:                           
                                                         
 - WebService 1.6.0      - FusionInventory 0.90.1.0      
 - Dashboard 0.6.9       - Racks 1.6.1                   
 - SimCard 1.4.1                                         
---------------------------------------------------------
" 0 0 0 

# Baixando o GLPI

wget https://github.com/glpi-project/glpi/releases/download/0.90/glpi-0.90.tar.gz
(pv -n glpi-0.90.tar.gz | tar zxf - ) 2>&1 | whiptail --title "${TITULO}" --backtitle "${BANNER}" --gauge "         Aguarde descompactando GLPI" 10 50 0
mv glpi /var/www/html/

# Baixando o Webservice
wget https://forge.glpi-project.org/attachments/download/2099/glpi-webservices-1.6.0.tar.gz
(pv -n glpi-webservices-1.6.0.tar.gz | tar zxf - ) 2>&1 | whiptail --title "${TITULO}" --backtitle "${BANNER}" --gauge "         Aguarde descompactando GLPI-WEBSERVICES" 10 50 0
mv webservices /var/www/html/glpi/plugins/

# Baixando o Racks
wget https://github.com/InfotelGLPI/racks/releases/download/1.6.1/glpi-racks-1.6.1.tar.gz
(pv -n  glpi-racks-1.6.1.tar.gz | tar zxf - ) 2>&1 | whiptail --title "${TITULO}" --backtitle "${BANNER}" --gauge "         Aguarde descompactando GLPI-RACKS" 10 50 0
mv racks /var/www/html/glpi/plugins/

# Baixando o DashBoard
wget https://forge.glpi-project.org/attachments/download/2113/GLPI-dashboard_plugin-0.6.9.tar.gz
(pv -n GLPI-dashboard_plugin-0.6.9.tar.gz | tar zxf - ) 2>&1 | whiptail --title "${TITULO}" --backtitle "${BANNER}" --gauge "         Aguarde descompactando GLPI-PLUGIN" 10 50 0
mv dashboard /var/www/html/glpi/plugins/

# Baixando SimCard Beta
wget https://github.com/pluginsGLPI/simcard/archive/1.4.1.tar.gz
(pv -n 1.4.1.tar.gz | tar zxf - ) 2>&1 | whiptail --title "${TITULO}" --backtitle "${BANNER}" --gauge "         Aguarde descompactando SIMCARD" 10 50 0
mv simcard-1.4.1 /var/www/html/glpi/plugins/simcard

# Baixando FusionInventory
wget "https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi090%2B1.0/fusioninventory-for-glpi_0.90.1.0.tar.gz"
(pv -n fusioninventory-for-glpi_0.90.1.0.tar.gz | tar zxf - ) 2>&1 | whiptail --title "${TITULO}" --backtitle "${BANNER}" --gauge "         Aguarde descompactando SIMCARD" 10 50 0
mv fusioninventory /var/www/html/glpi/plugins/

# Adequando Apache

echo -e "<Directory \"/var/www/html/glpi\">
    AllowOverride All
</Directory>

" > /etc/apache2/conf-available/glpi.conf

a2enconf glpi.conf
systemctl restart apache2 

# Adequando permissões nos arquivos
chmod 775 /var/www/html -Rf
chown www-data:www-data /var/www/html -Rf

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Configurando Banco de dados para o GLPI

clear


whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
         Configuração do Banco de Dados do GLPI          
---------------------------------------------------------
                                                         
 Procederemos agora com a criação de uma conta para      
 gerenciamento do banco de dados do sistema GLPI.        
 Por praticidade, criaremos:                             
---------------------------------------------------------    
 - Uma base de dados de nome GLPI e,                     
 - Uma conta de administração da Base de dados de        
 nome 'glpi'.                                            
 --------------------------------------------------------

" 0 0 0 

rootMariaPWD=$(whiptail --title "${TITULO}" \
                        --backtitle "${BANNER}" \
                        --inputbox "Informe a senha do usuario root do MariaDB." 0 0 3>&1 1>&2 2>&3)

pwdGLPIBD=$(whiptail --title "${TITULO}" \
                     --backtitle "${BANNER}" \
                     --inputbox "Informe a senha do usuario usado pelo sistema." 0 0 3>&1 1>&2 2>&3)

mysql -u root -p$rootMariaPWD -e "create database glpi";
mysql -u root -p$rootMariaPWD -e "create user 'glpi'@'localhost' identified by '$pwdGLPIBD'";
mysql -u root -p$rootMariaPWD -e "grant all on glpi.* to glpi with grant option";

clear

whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
         Configuração do Banco de Dados do GLPI          
---------------------------------------------------------
                                                         
 Ok! Criamos então:                                      
                                                         
 - Uma base de dados de nome GLPI e,                     
 - Uma conta de administração da Base de dados de nome   
 'glpi'.                                                 
---------------------------------------------------------
 Tome nota dos dados pois serão necessários para         
 finalizar as configurações dos sistemas via WEB         
---------------------------------------------------------
" 0 0 0

# Realizando a integração do Zabbix com o GLPI
whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "

      Realizando a Integração do Zabbix com o GLPI       
---------------------------------------------------------
                                                         
 Agora, realizaremos a instalação de alguns scripts      
 desenvolvidos originalmente por:                        
 Janssen dos Reis Lima <janssenreislima@gmail.com>       
 Estes scripts ficarão armazenados em:                   
---------------------------------------------------------
 /usr/lib/zabbix/externalscripts/                        
				ack_zabbix_glpi.py       
				tickets_zabbix_glpi.php   
				zabbix_api.py             
                                                         
 Precisaremos de algumas respostas ainda para que seja   
 possível prosseguirmos com a configuração:              
 ---------------------------------------------------------
" 0 0 0 
clear
# -------------------------------------------------------------------

GLPI_USER=glpi
read -s GLPI_USER_PWD
GLPI_IP_ADDRESS=127.0.0.1
SQL_GLPI_DB=127.0.0.1
GLPI_DB=glpi
GLPI_DB_USER=glpi
GLPI_DB_USER_PWD=$pwdGLPIBD

# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Criando ack_zabbix_glpi.py
# COLOCAR ESTE SCRIPT EM UM SERVIDOR WEB QUALQUER PARA EVITAR DE POLUIR O INSTALADOR
echo "FAVOR ADICIONAR ESSE SCRIPT (ack_zabbix_glpi.py) EM UM SERVIDOR WEB"
echo "wget http://SERVIDOR/ack_zabbix_glpi.py -O /usr/lib/zabbix/externalscripts/ack_zabbix_glpi.py"
read x 

# ----------------------------------------------------

# Criando tickets_zabbix_glpi.php

echo "FAVOR ADICIONAR ESSE SCRIPT (tickets_zabbix_glpi.php) EM UM SERVIDOR WEB"
echo "wget http://SERVIDOR/tickets_zabbix_glpi.php -O /usr/lib/zabbix/externalscripts/tickets_zabbix_glpi.php"
read x
# ----------------------------------------------------

# Criando zabbix_api.py 
echo "FAVOR ADICIONAR ESSE SCRIPT (zabbix_api.py) EM UM SERVIDOR WEB"
echo "wget http://SERVIDOR/zabbix_api.py -O /usr/lib/zabbix/externalscripts/zabbix_api.py"
read x

# Adequando acessos
chown zabbix:zabbix /usr/lib/zabbix/externalscripts/ -Rf
chmod 775 /usr/lib/zabbix/externalscripts/* -Rf


# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Mensagem de finalização

clear

whiptail --title "${TITULO}" \
         --backtitle "${BANNER}" \
         --msgbox "
                  PROCESSO FINALIZADO                    
---------------------------------------------------------
                                                         
 Aparentemente terminamos o processo de instalação!      
 Agora, acesse o seu servidor externamente a partir      
 de um web browser:                                      
                                                         
 HTTP://IP_SERVIDOR/zabbix                               
 HTTP://IP_SERVIDOR/glpi                                 
                                                         
 Abaixo serão exibidos os possíveis endereços deste      
 servidor:                                               
---------------------------------------------------------
" 0 0 0 
