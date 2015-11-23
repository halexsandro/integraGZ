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
# Saudação

clear

echo -e "
 #########################################################	
# Olá,                                                    #
# Este script tem por objetivo realizar a instalação  dos #
# seguintes sistemas de forma automatizada:               #
# - Zabbix 2.4.6.1 [http://zabbix.com]                    #
# - GLPI 0.90 [http://glpi-project.com                    #
  ------------------------------------------------------- 
# Fora os aplicativos citados, serão instalados recursos  #
# adicionais que permitem a integração do Zabbix com GLPI #
# e alguns plugins úteis do GLPI de forma a economizar    #
# tempo do Administrador.                                 #
  -------------------------------------------------------
| integraGZ.sh | versão 0.1                               |
| Desenvolvido por: Halexsandro de Freitas Sales          |
| Contato: halexsandro@gmail.com                          |
|---------------------------------------------------------|
|                http://www.pillares.net                  |
 ---------------------------------------------------------
 - Tecle 'ENTER'
"

read -n1 opt

clear

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Verificar se o usuário é o ROOT

if [ $UID -ne 0 ]
then
	clear
	echo -e "
 #########################################################	
# ERRO: Falta de acesso/privilégio                        #
# É necessário acesso de Administrador do Sistema         #
 ---------------------------------------------------------
#                                                         #
#            Encerrarei este processo agora!              #
#                                                         #
# Você precisa estar logado como root para executar este  #
# script.                                                 #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------
"
	kill $$
fi
# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Detectar a versão do sistema operacional

debianVersion=$(cat /etc/debian_version | cut -d"." -f1 )

if [ $debianVersion -ne 8 ]
then
	clear 
	echo -e "
 #########################################################	
#        ERRO: Sistema Operacional não suportado          #
 ---------------------------------------------------------
#                                                         #
#            Encerrarei este processo agora!              #
#                                                         #
# Este script foi desenvolvido para o Debian 8.           #
#                                                         #
# Caso tenha alguma dúvida ou acredite que esta           #
# informação esteja errada, favor entrar em contato!      #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------
"

	kill $$
fi

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Detectando a arquitetura do Sistema

arch=$(uname -m)

case $arch in 

	i686)
		arch=i386
		;;
	i586)
		arch=i386
		;;
	i486)
		arch=i386
		;;
	i386)
		arch=i386
		;;

	x86_64)
		arch=amd64
		;;

	*)
		echo -e "

 ##########################################################
# ERRO: Arquitetura do Processador não suportada           #
 ----------------------------------------------------------
#                                                          #
#             Encerrarei este processo agora!              #
#                                                          #
# Este script foi desenvolvido para as seguintes           #
# arquiteturas:                                            #
# - i386, i486, i586, i686 [32 bits]                       #
# - x86_64 [64 bits]                                       #
#                                                          #
# Caso tenha alguma dúvida ou acredite que esta informação #
# esteja errada, favor entrar em contato!                  #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

"
		kill $$
;;

esac
# FIM ---------------------------------------------------------------


# -------------------------------------------------------------------
# Instalando dependências

echo -e "
 #########################################################	
#           Requisitos de sistema atendidos!              #
 ----------------------------------------------------
#                                                         #
# Um dos programas instalados trata-se do MariaDB. Durante#
# a instalação será solicitado uma senha para o usuário   #
# administrativo do Banco de Dados.                       #
# Também será solicitada uma senha para o usuário do banco#
# de dados Zabbix. Estas senhas não precisam ser iguais   #
# mas, serão necessárias para configurarmos o ambiente do #
# Zabbix pela interface WEB.                              #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------
"

echo -e "
Precione ENTER para continuar ou CTRL + C para cancelar!
"
read -n1 a

clear

echo -e "
Estou agora adicionando os repositórios do Debian...
"
sleep 2

clear

# Realizando cópia de segurança de sources.list

if [ -e /etc/apt/sources.list-ori ]
then
	clear
	echo -e "
 #########################################################	
#         Script já executado neste computador!           #
 ---------------------------------------------------------
#                                                         #
# Aparentemente este script já foi executado neste        #
# computador.                                             #
# Portanto, não faremos backup novamente do arquivo       #
# '/etc/apt/sources.list'.                                #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

 - Para cancelar, pressione 'C'.
 - Para continuar, pressione qualquer outra tecla!
"

	read -n1 opt

	if [ $opt = c ] || [ $opt = C ]
		then
		kill $$
	fi

else
	cat /etc/apt/sources.list > /etc/apt/sources.list-ori

fi

echo "deb http://ftp.br.debian.org/debian/ jessie main" > /etc/apt/sources.list
echo "deb-src http://ftp.br.debian.org/debian/ jessie main" >> /etc/apt/sources.list

echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list

echo "deb http://ftp.br.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
echo "deb-src http://ftp.br.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list

echo "deb http://ftp.de.debian.org/debian/ jessie main non-free" >> /etc/apt/sources.list

clear 

echo -e "
 #########################################################	
#              Instalação de Pacotes                      #
 ---------------------------------------------------------
#                                                         #
# Realizaremos agora a instalação de softwares que são    #
# necessários para o correto funcionamento dos sistemas   #
# Zabbix e GLPI. Dentre estes estão:                      #
#  - Banco de Dados MariaDB                               #
#  - Servidor HTTP Apache                                 #
#  - Suporte a linguagem PHP                              #
#  - Suporte ao protocolo SNMP                            #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

- Para continuar, pressione qualquer outra tecla!
"

read -n1 opt

apt-get update

apt-get install mariadb-server apache2 apache2-mpm-prefork apache2-utils apache2.2-bin apache2.2-common php-soap php5 php5-cli php5-common php5-gd php5-mysql php5-xmlrpc libapache2-mod-php5 php5-imap php5-ldap snmp snmp-mibs-downloader fping ca-certificates ttf-dejavu-core libcurl3 librtmp1 dbconfig-common libdbi-perl libiksemel3 libodbc1 libopenipmi0 libssh2-1 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libonig2 libqdbm14 zip unzip bzip2 unrar-free -y


# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Download e instalação dos pacotes ZABBIX

clear

echo -e "
 #########################################################	
#     Dependências resolvidas - Ambiente pronto!          #
 ----------------------------------------------------
#                                                         #
# Tudo Certo! Seu servidor está pronto para receber os    #
# sistemas Zabbix e GLPI.                                 #
#                                                         #
# Procederemos agora com a instalação do Zabbix.          #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

- Para continuar, pressione qualquer tecla!
"
read -n1 opt

#Baixando e instalando os pacotes do Zabbix

cd /tmp

wget http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix/zabbix-agent_2.4.6-1+jessie_$arch.deb
wget http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix/zabbix-get_2.4.6-1+jessie_$arch.deb
wget http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix/zabbix-sender_2.4.6-1+jessie_$arch.deb
wget http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix/zabbix-server-mysql_2.4.6-1+jessie_$arch.deb
wget http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix/zabbix-frontend-php_2.4.6-1+jessie_all.deb

clear

echo -e "
 #########################################################	
#                Pacotes Baixados...                      #
 ---------------------------------------------------------
#                                                         #
# Iniciando instalação do Zabbix.                         #
#                                                         #
# Responda <SIM> a pergunta de configuração do banco      #
# de dados do sistema.                                    #
# A primeira senha solicitada é a do usuário Root do SGBD #
# MariaDB que você cadastrou anteriormente.               #
# Na sequência, será solicitada uma senha para o usuário  #
# zabbix que será criado no MariaDB                       #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

- Para continuar, pressione qualquer tecla!
"
read -n1 opt

# Instalando pacotes

dpkg -i zabbix-agent_2.4.6-1+jessie_$arch.deb
dpkg -i zabbix-get_2.4.6-1+jessie_$arch.deb
dpkg -i zabbix-sender_2.4.6-1+jessie_$arch.deb
dpkg -i zabbix-server-mysql_2.4.6-1+jessie_$arch.deb
dpkg -i zabbix-frontend-php_2.4.6-1+jessie_all.deb

# -------------------------------------------------------------------
# Adequando as variáveis do PHP para uso no Apache

clear

echo -e "
 #########################################################
#          Configurando detalhes do Zabbix                #
 ---------------------------------------------------------
# Essa configuração é necessária para o Zabbix mas pode   #
# ser alterada manualmente editando o seguinte arquivo:   #
 --------------------------------------------------------
#       /etc/apache2/conf-enabled/zabbix.conf             #
 --------------------------------------------------------
# 11 - Bahia             12 - Belem                       #
# 13 - Campo_Grande      14 - Fortaleza                   #
# 15 - Maceio            16 - Manaus                      #
# 17 - Noronha           18 - Porto_Velho                 #
# 19 - Recife            20 - Rio_Branco                  #
# 21 - Sao_Paulo                                          #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

- Digite o Código do TimeZone escolhido:
"
read -n2 TimeZone

case $TimeZone in

	11)
		TimeZone=Bahia
	;;

	12)
		TimeZone=Belem
	;;

	13)
		TimeZone=Campo_Grande
	;;

	14)
		TimeZone=Fortaleza
	;;

	15)
		TimeZone=Maceio
	;;

	16)
		TimeZone=Manaus
	;;

	17)
		TimeZone=Noronha
	;;

	18)
		TimeZone=Porto_Velho
	;;

	19)
		TimeZone=Recife
	;;
	
	20)
		TimeZone=Rio_Branco
	;;
	
	21)
		TimeZone=Sao_Paulo
	;;
	
	*)
		TimeZone=Sao_Paulo
	;;
esac

# Adequando PHP para o Zabbix
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/'$TimeZone'\n    php_value always_populate_raw_post_data -1/' /etc/apache2/conf-enabled/zabbix.conf

# Habilitando Execução de Scripts via ZabbixAgent
sed -i 's/# EnableRemoteCommands=0*/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf

# Reiniciando o serviço Zabbix e Apache

service zabbix-server restart
service zabbix-agent restart
service apache2 restart

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Instalação do GLPI e do WEB Service

clear

echo -e "
 #########################################################	
#                   Instalação do GLPI                    #
 ---------------------------------------------------------
#                                                         #
# O processo de instalação do Zabbix foi finalizado.      #
# Procederemos agora com a instalação do GLPI e de alguns #
# plugins úteis:                                          #
 ---------------------------------------------------------
# Plugins que serão Instalados:                           #
#                                                         #
# - WebService 1.6.0      - FusionInventory 0.90.1.0      #
# - Dashboard 0.6.9       - Racks 1.6.1                   #
# - SimCard 1.4.1                                         #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

- Para continuar, pressione qualquer tecla!
"
read -n1 opt

# Baixando o GLPI

wget https://github.com/glpi-project/glpi/releases/download/0.90/glpi-0.90.tar.gz
tar -zxvf glpi-0.90.tar.gz
mv glpi /var/www/html/

# Baixando o Webservice
wget https://forge.glpi-project.org/attachments/download/2099/glpi-webservices-1.6.0.tar.gz
tar -zxvf glpi-webservices-1.6.0.tar.gz
mv webservices /var/www/html/glpi/plugins/

# Baixando o Racks
wget https://github.com/InfotelGLPI/racks/releases/download/1.6.1/glpi-racks-1.6.1.tar.gz
tar -zxvf glpi-racks-1.6.1.tar.gz
mv racks /var/www/html/glpi/plugins/

# Baixando o DashBoard
wget https://forge.glpi-project.org/attachments/download/2113/GLPI-dashboard_plugin-0.6.9.tar.gz
tar -zxvf GLPI-dashboard_plugin-0.6.9.tar.gz
mv dashboard /var/www/html/glpi/plugins/

# Baixando SimCard Beta
wget https://github.com/pluginsGLPI/simcard/archive/1.4.1.tar.gz
tar -zxvf 1.4.1.tar.gz
mv simcard-1.4.1 /var/www/html/glpi/plugins/simcard

# Baixando FusionInventory
wget "https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi090%2B1.0/fusioninventory-for-glpi_0.90.1.0.tar.gz"
tar -zxvf "fusioninventory-for-glpi_0.90.1.0.tar.gz"
mv fusioninventory /var/www/html/glpi/plugins/

# Adequando Apache

echo -e "<Directory \"/var/www/html/glpi\">
    AllowOverride All
</Directory>

" > /etc/apache2/conf-available/glpi.conf

a2enconf glpi.conf
service apache2 restart

# Adequando permissões nos arquivos
chmod 775 /var/www/html -Rf
chown www-data:www-data /var/www/html -Rf

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Configurando Banco de dados para o GLPI

clear

echo -e "
 #########################################################	
#         Configuração do Banco de Dados do GLPI          #
 ---------------------------------------------------------
#                                                         #
# Procederemos agora com a criação de uma conta para      #
# gerenciamento do banco de dados do sistema GLPI.        #
# Por praticidade, criaremos:                             #
 ---------------------------------------------------------     
# - Uma base de dados de nome GLPI e,                     #
# - Uma conta de administração da Base de dados de        #
# nome 'glpi'.                                            #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

 - Informe a senha do usuário root do MariaDB criada durante esta
   instalação e pressione <ENTER> [a senha não será impressa na tela]:
"
read -s rootMariaPWD

echo -e "
---
 - Informe agora uma senha para o usuário GLPI usado pelo sistema e 
 pressione <ENTER> [a senha não será impressa na tela]:

"

read -s pwdGLPIBD

mysql -u root -p$rootMariaPWD -e "create database glpi";
mysql -u root -p$rootMariaPWD -e "create user 'glpi'@'localhost' identified by '$pwdGLPIBD'";
mysql -u root -p$rootMariaPWD -e "grant all on glpi.* to glpi with grant option";

clear

echo -e "
 #########################################################	
#         Configuração do Banco de Dados do GLPI          #
 ---------------------------------------------------------
#                                                         #
# Ok! Criamos então:                                      #
#                                                         #
# - Uma base de dados de nome GLPI e,                     #
# - Uma conta de administração da Base de dados de nome   #
# 'glpi'.                                                 #
 ---------------------------------------------------------
# Tome nota dos dados pois serão necessários para         #
# finalizar as configurações dos sistemas via WEB         #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

 - Precione qualquer tecla para continuar...
"
read -n1 opt

# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Realizando a integração do Zabbix com o GLPI

clear

echo -e "
 #########################################################	
#      Realizando a Integração do Zabbix com o GLPI       #
 ---------------------------------------------------------
#                                                         #
# Agora, realizaremos a instalação de alguns scripts      #
# desenvolvidos originalmente por:                        #
# Janssen dos Reis Lima <janssenreislima@gmail.com>       #
# Estes scripts ficarão armazenados em:                   #
 ---------------------------------------------------------
# /usr/lib/zabbix/externalscripts/                        #
#				ack_zabbix_glpi.py        #
#				tickets_zabbix_glpi.php   #
#				zabbix_api.py             #
#                                                         #
# Precisaremos de algumas respostas ainda para que seja   #
# possível prosseguirmos com a configuração:              #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------

 - Precione qualquer tecla para continuar...
"
read -n1 opt

clear

# -------------------------------------------------------------------

GLPI_USER=glpi
echo -e "Informe a senha que pretende colocar no usuário GLPI [nenhum caracter será impresso na tela]:"
read -s GLPI_USER_PWD
GLPI_IP_ADDRESS=127.0.0.1
SQL_GLPI_DB=127.0.0.1
GLPI_DB=glpi
GLPI_DB_USER=glpi
GLPI_DB_USER_PWD=$pwdGLPIBD

# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Criando ack_zabbix_glpi.py

echo -e "
## Autor: Janssen dos Reis Lima <contato@janssenlima.com / janssenreislima@gmail.com>
## Ultima atualizacao: 02/06/2015
## Observacoes: Este script eh executado automaticamente apos a abertura do ticket no GLPI
 
from zabbix_api import ZabbixAPI
import sys
  
server = \"http://localhost/zabbix\"
username = \"admin\"            
password = \"zabbix\"    
  
conexao = ZabbixAPI(server = server)
conexao.login(username, password)
 
reconhecer_evento = conexao.event.acknowledge({\"eventids\": sys.argv[1], \"message\": \"Ticket \" + str(sys.argv[2]) + \" criado no GLPI.\"})


" > /usr/lib/zabbix/externalscripts/ack_zabbix_glpi.py

# ----------------------------------------------------

# Criando tickets_zabbix_glpi.php

echo -e "
<?php
// ----------------------------------------------------------------------------------------
// Autor: Janssen dos Reis Lima <contato@janssenlima.com / janssenreislima@gmail.com>
// Script: tickets_zabbix_glpi.php
// Ultima Atualizacao: 02/06/2015
 
// -----------------------------------------------------------------------------------------
// Configuracoes:
// -----------------------------------------------------------------------------------------
\$user =         \"$GLPI_USER\";                     
\$password =     \"$GLPI_USER_PWD\";                     
\$xmlhost =      \"$GLPI_IP_ADDRESS\";                 
\$xmlurl =       \"glpi/plugins/webservices/xmlrpc.php\";  
\$category =     \"\";                     
\$watcher =  \"2\";                        
\$watchergroup = \"1\";                        
\$sqlhost =  \"$SQL_GLPI_DB\";                 
\$sqldb =    \"$GLPI_DB\";                   
\$sqluser =      \"$GLPI_DB_USER\";                                 
\$sqlpwd =       \"$GLPI_DB_USER_PWD\";                             
\$path_zabbix =  \"/usr/lib/zabbix/externalscripts\";
             
// ------------------------------------------------------------------------------------------------------------------------
 
\$arg[] = \"method=glpi.test\";
\$arg[] = \"url=\$xmlurl\";
\$arg[] = \"host=\$xmlhost\";
\$response = getxml(\$arg);
unset(\$arg);
\$webservices_version = \$response['webservices'];
 
\$eventval=array();
if (\$argv>1) {
    for (\$i=1 ; \$i<count(\$argv) ; \$i++) {
        \$it = explode(\"=\",\$argv[\$i],2);
        \$it[0] = preg_replace('/^--/','',\$it[0]);
        \$eventval[\$it[0]] = (isset(\$it[1]) ? \$it[1] : true);
    }
}
 
\$eventhost=\$eventval['eventhost'];
\$event=\$eventval['event'];
\$state=\$eventval['state'];
\$hostproblemid=\$eventval['hostproblemid'];
\$lasthostproblemid=\$eventval['lasthostproblemid'];
\$servico=\$eventval['servico'];
\$eventzabbix=\$eventval['eventzabbix'];
\$triggerid=\$eventval['triggerid'];
unset(\$eventval);
 
function getxml(\$arg) {
    \$args=array();
    if (\$arg>1) {
       for (\$i=0 ; \$i<count(\$arg) ; \$i++) {
          \$it = explode(\"=\",\$arg[\$i],2);
          \$it[0] = preg_replace('/^--/','',\$it[0]);
          if (strpos(\$it[1],',') !== false) {
            \$it[1] = explode(\",\", \$it[1]);
          }
          \$args[\$it[0]] = (isset(\$it[1]) ? \$it[1] : true);
       }
    }
    \$method=\$args['method'];
    \$url=\$args['url'];
    \$host=\$args['host'];
     
    if (isset(\$args['session'])) {
       \$url.='?session='.\$args['session'];
       unset(\$args['session']);
    }
 
    \$header = \"Content-Type: text/xml\";
 
    echo \"+ Calling '\$method' on http://\$host/\$url\n\";
     
    \$request = xmlrpc_encode_request(\$method, \$args);
    \$context = stream_context_create(array('http' => array('method'  => \"POST\",
                                                           'header'  => \$header,
                                                           'content' => \$request)));
 
    \$file = file_get_contents(\"http://\$host/\$url\", false, \$context);
    if (!\$file) {
       die(\"+ No response\n\");
    }
 
    if (in_array('Content-Encoding: deflate', \$http_response_header)) {
       \$lenc=strlen(\$file);
       echo \"+ Compressed response : \$lenc\n\";
       \$file = gzuncompress(\$file);
       \$lend=strlen(\$file);
       echo \"+ Uncompressed response : \$lend (\".round(100.0*\$lenc/\$lend).\"%)\n\";
    }
    \$response = xmlrpc_decode(\$file);
    if (!is_array(\$response)) {
       echo \$file;
       die (\"+ Bad response\n\");
    }
 
    if (xmlrpc_is_fault(\$response)) {
        echo(\"xmlrpc error(\".\$response['faultCode'].\"): \".\$response['faultString'].\"\n\");
    } else {
       return \$response;
    }
}
 
if (!extension_loaded(\"xmlrpc\")) {
   die(\"Extension xmlrpc not loaded\n\");
}
 
switch (\$event) {
    case \"UP\":
        if (\$lasthostproblemid != 0) { 
            \$arg[] = \"method=glpi.doLogin\";
            \$arg[] = \"url=\$xmlurl\";
            \$arg[] = \"host=\$xmlhost\";
            \$arg[] = \"login_password=\$password\";
            \$arg[] = \"login_name=\$user\";
 
            \$response = getxml(\$arg);
            \$session = \$response['session'];
             
            \$mysql = mysql_connect(\$sqlhost, \$sqluser, \$sqlpwd) or die(mysql_error());
      mysql_select_db(\$sqldb) or die(mysql_error());
            \$consulta_chamado = mysql_query(\"SELECT id FROM glpi_tickets WHERE status <> 5 AND content like '%\$triggerid%'\");
 
            \$pega_id_ticket = mysql_fetch_array(\$consulta_chamado);
            \$num_ticket = \"{\$pega_id_ticket['id']}\";
 
            mysql_query(\"UPDATE glpi_tickets SET status='5' WHERE id='\$num_ticket'\") or die(mysql_error());
 
            mysql_close(\$mysql);
             
            \$content = \"\$state: \$servico. Registro fechado automaticamente atraves do evento \$eventzabbix.\";
                         
            \$arg[] = \"method=glpi.addTicketFollowup\";
            \$arg[] = \"url=\$xmlurl\";
            \$arg[] = \"host=\$xmlhost\";
            \$arg[] = \"session=\$session\";
            \$arg[] = \"ticket=\$num_ticket\";
            \$arg[] = \"content=\$content\";
            \$resp = getxml(\$arg);
            unset(\$arg);
            unset(\$resp);
             
            \$arg[] = \"method=glpi.doLogout\";
            \$arg[] = \"url=\$xmlurl\";
            \$arg[] = \"host=\$xmlhost\";
            \$arg[] = \"session=\$session\";
 
            \$response = getxml(\$arg);
            unset(\$arg);
            unset(\$response);
        }
    case \"DOWN\":
            switch (\$state) {
                case \"PROBLEM\":
                    if (\$lasthostproblemid != 1) {
                        \$arg[] = \"method=glpi.doLogin\";
                        \$arg[] = \"url=\$xmlurl\";
                        \$arg[] = \"host=\$xmlhost\";
                        \$arg[] = \"login_password=\$password\";
                        \$arg[] = \"login_name=\$user\";
 
                        \$response = getxml(\$arg);
                        \$session = \$response['session'];
 
                        unset(\$arg);
                        unset(\$response);
                        if (!empty(\$session)) {
                             
                            \$title = \"\$state: \$servico! - Evento \$eventzabbix gerado automaticamente pelo Zabbix\";
                            \$content = \"Nome do host: \$eventhost. ID da trigger: \$triggerid. Status da trigger: \$state.\";
                            if (\$category != ''){
                                \$arg[] = \"method=glpi.listDropdownValues\";
                                \$arg[] = \"url=\$xmlurl\";
                                \$arg[] = \"host=\$xmlhost\";
                                \$arg[] = \"session=\$session\";
                                \$arg[] = \"dropdown=itilcategories\";
                                \$arg[] = \"name=\$category\";
                                \$response = getxml(\$arg);
                                \$categoryid = \$response[0]['id'];
                                unset(\$arg);
                                \$catarg = \"category=\$categoryid\";
                            }
                            if (!empty(\$watcher)) {
                                \$watcherarg = \"observer=\$watcher\";
                            } elseif (!empty(\$watchergroup)) {
                                \$arg[] = \"method=glpi.listUsers\";
                                \$arg[] = \"url=\$xmlurl\";
                                \$arg[] = \"host=\$xmlhost\";
                                \$arg[] = \"session=\$session\";
                                \$arg[] = \"group=\$watchergroup\";
                                \$response = getxml(\$arg);
                                foreach(\$response as \$user){
                                    \$watcherids .= \$user['id'].\",\";
                                }
                                \$watcherids = rtrim(\$watcherids, \",\");
                                \$watcherarg = \"observer=\$watcherids\";
                                unset(\$arg);
                            } else {
                                // uso futuro
                            }
                             
                             
                            \$arg[] = \"method=glpi.createTicket\";
                            \$arg[] = \"url=\$xmlurl\";
                            \$arg[] = \"host=\$xmlhost\";
                            \$arg[] = \"session=\$session\";
                            \$arg[] = \"title=\$title\";
                            \$arg[] = \"content=\$content\";
                            \$arg[] = \"urgancy=5\";
 
                            if (!empty(\$catarg)) \$arg[] = \$catarg;
                            if (!empty(\$watcherarg)) \$arg[] = \$watcherarg;
                                                        if (str_replace(\".\", \"\", \$webservices_version) >= '120') {
                                                                \$arg[] = \"use_email_notification=1\";
                                                        }
                            \$response = getxml(\$arg);
                            unset(\$arg);
                            unset(\$response);
 
                                    \$mysql = mysql_connect(\$sqlhost, \$sqluser, \$sqlpwd) or die(mysql_error());
                                    mysql_select_db(\$sqldb) or die(mysql_error());
                                    \$consulta_evento = mysql_query(\"SELECT id FROM glpi_tickets WHERE name like '%\$eventzabbix%'\") or die(mysql_error());
                     
                                    \$pega_id_ticket = mysql_fetch_array(\$consulta_evento);
                                    \$num_ticket = \"{\$pega_id_ticket['id']}\";
                                    sleep(10);
                                    \$comando = \"python \$path_zabbix/ack_zabbix_glpi.py \$eventzabbix \$num_ticket\";
                                    \$output = shell_exec(\$comando);
                                    mysql_close(\$mysql);
                         
                            \$arg[] = \"method=glpi.doLogout\";
                            \$arg[] = \"url=\$xmlurl\";
                            \$arg[] = \"host=\$xmlhost\";
                            \$arg[] = \"session=\$session\";
     
                            \$response = getxml(\$arg);
                            unset(\$arg);
                            unset(\$response);
                        }
                    }
            }
}
 
 
?>

"  > /usr/lib/zabbix/externalscripts/tickets_zabbix_glpi.php

# ----------------------------------------------------

# Criando zabbix_api.py 

echo -e "
# This is a port of the ruby zabbix api found here:
# http://trac.red-tux.net/browser/ruby/api/zbx_api.rb
#
#LGPL 2.1   http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
#Zabbix API Python Library.
#Original Ruby Library is Copyright (C) 2009 Andrew Nelson nelsonab(at)red-tux(dot)net
#Python Library is Copyright (C) 2009 Brett Lentz brett.lentz(at)gmail(dot)com
#
#This library is free software; you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public
#License as published by the Free Software Foundation; either
#version 2.1 of the License, or (at your option) any later version.
#
#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Lesser General Public License for more details.
#
#You should have received a copy of the GNU Lesser General Public
#License along with this library; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 
# NOTES:
# The API requires zabbix 1.8 or later.
# Currently, not all of the API is implemented, and some functionality is
# broken. This is a work in progress.

import base64
import hashlib
import logging
import string
import sys
try:
    import urllib2
except ImportError:
	import urllib.request as urllib2  # python3
import re
from collections import deque
 
default_log_handler = logging.StreamHandler(sys.stdout)
__logger = logging.getLogger(\"zabbix_api\")
__logger.addHandler(default_log_handler)
__logger.log(10, \"Starting logging\")
 
try:
    # Separate module or Python <2.6
    import simplejson as json
    __logger.log(15, \"Using simplejson library\")
except ImportError:
    # Python >=2.6
    import json
    __logger.log(15, \"Using native json library\")
 
 
def checkauth(fn):
    \"\"\" Decorator to check authentication of the decorated method \"\"\"
    def ret(self, *args):
        self.__checkauth__()
        return fn(self, args)
    return ret
 
 
def dojson(name):
    def decorator(fn):
        def wrapper(self, opts):
            self.logger.log(logging.DEBUG, \
                    \"Going to do_request for %s with opts %s\" \
                    % (repr(fn), repr(opts)))
            return self.do_request(self.json_obj(name, opts))['result']
        return wrapper
    return decorator
 
 
def dojson2(fn):
    def wrapper(self, method, opts):
        self.logger.log(logging.DEBUG, \
                \"Going to do_request for %s with opts %s\" \
                % (repr(fn), repr(opts)))
        return self.do_request(self.json_obj(method, opts))['result']
    return wrapper
 
 
class ZabbixAPIException(Exception):
    \"\"\" generic zabbix api exception
    code list:
         -32602 - Invalid params (eg already exists)
         -32500 - no permissions
    \"\"\"
    pass
 
 
class Already_Exists(ZabbixAPIException):
    pass
 
 
class InvalidProtoError(ZabbixAPIException):
    \"\"\" Recived an invalid proto \"\"\"
    pass
 
 
class ZabbixAPI(object):
    __username__ = ''
    __password__ = ''
 
    auth = ''
    url = '/api_jsonrpc.php'
    params = None
    method = None
    # HTTP or HTTPS
    proto = 'http'
    # HTTP authentication
    httpuser = None
    httppasswd = None
    timeout = 10
    # sub-class instances.
    user = None
    usergroup = None
    host = None
    item = None
    hostgroup = None
    hostinterface = None
    application = None
    trigger = None
    sysmap = None
    template = None
    drule = None
    # Constructor Params:
    # server: Server to connect to
    # path: Path leading to the zabbix install
    # proto: Protocol to use. http or https
    # We're going to use proto://server/path to find the JSON-RPC api.
    #
    # user: HTTP auth username
    # passwd: HTTP auth password
    # log_level: logging level
    # r_query_len: max len query history
    # **kwargs: Data to pass to each api module
 
    def __init__(self, server='http://localhost/zabbix', user=httpuser, passwd=httppasswd,
                 log_level=logging.WARNING, timeout=10, r_query_len=10, **kwargs):
        \"\"\" Create an API object.  \"\"\"
        self._setuplogging()
        self.set_log_level(log_level)
        self.server = server
        self.url = server + '/api_jsonrpc.php'
        self.proto = self.server.split(\"://\")[0]
        #self.proto=proto
        self.httpuser = user
        self.httppasswd = passwd
        self.timeout = timeout
        self.usergroup = ZabbixAPISubClass(self, dict({\"prefix\": \"usergroup\"}, **kwargs))
        self.user = ZabbixAPISubClass(self, dict({\"prefix\": \"user\"}, **kwargs))
        self.host = ZabbixAPISubClass(self, dict({\"prefix\": \"host\"}, **kwargs))
        self.item = ZabbixAPISubClass(self, dict({\"prefix\": \"item\"}, **kwargs))
        self.hostgroup = ZabbixAPISubClass(self, dict({\"prefix\": \"hostgroup\"}, **kwargs))
        self.hostinterface = ZabbixAPISubClass(self, dict({\"prefix\": \"hostinterface\"}, **kwargs))
        self.application = ZabbixAPISubClass(self, dict({\"prefix\": \"application\"}, **kwargs))
        self.trigger = ZabbixAPISubClass(self, dict({\"prefix\": \"trigger\"}, **kwargs))
        self.template = ZabbixAPISubClass(self, dict({\"prefix\": \"template\"}, **kwargs))
        self.action = ZabbixAPISubClass(self, dict({\"prefix\": \"action\"}, **kwargs))
        self.alert = ZabbixAPISubClass(self, dict({\"prefix\": \"alert\"}, **kwargs))
        self.info = ZabbixAPISubClass(self, dict({\"prefix\": \"info\"}, **kwargs))
        self.event = ZabbixAPISubClass(self, dict({\"prefix\": \"event\"}, **kwargs))
        self.graph = ZabbixAPISubClass(self, dict({\"prefix\": \"graph\"}, **kwargs))
        self.graphitem = ZabbixAPISubClass(self, dict({\"prefix\": \"graphitem\"}, **kwargs))
        self.map = ZabbixAPISubClass(self, dict({\"prefix\": \"map\"}, **kwargs))
        self.screen = ZabbixAPISubClass(self, dict({\"prefix\": \"screen\"}, **kwargs))
        self.screenitem = ZabbixAPISubClass(self, dict({\"prefix\": \"screenitem\"}, **kwargs))
        self.script = ZabbixAPISubClass(self, dict({\"prefix\": \"script\"}, **kwargs))
        self.usermacro = ZabbixAPISubClass(self, dict({\"prefix\": \"usermacro\"}, **kwargs))
        self.drule = ZabbixAPISubClass(self, dict({\"prefix\": \"drule\"}, **kwargs))
        self.history = ZabbixAPISubClass(self, dict({\"prefix\": \"history\"}, **kwargs))
        self.maintenance = ZabbixAPISubClass(self, dict({\"prefix\": \"maintenance\"}, **kwargs))
        self.proxy = ZabbixAPISubClass(self, dict({\"prefix\": \"proxy\"}, **kwargs))
        self.apiinfo = ZabbixAPISubClass(self, dict({\"prefix\": \"apiinfo\"}, **kwargs))
        self.configuration = ZabbixAPISubClass(self, dict({\"prefix\": \"configuration\"}, **kwargs))
        self.dcheck = ZabbixAPISubClass(self, dict({\"prefix\": \"dcheck\"}, **kwargs))
        self.dhost = ZabbixAPISubClass(self, dict({\"prefix\": \"dhost\"}, **kwargs))
        self.discoveryrule = ZabbixAPISubClass(self, dict({\"prefix\": \"discoveryrule\"}, **kwargs))
        self.dservice = ZabbixAPISubClass(self, dict({\"prefix\": \"dservice\"}, **kwargs))
        self.iconmap = ZabbixAPISubClass(self, dict({\"prefix\": \"iconmap\"}, **kwargs))
        self.image = ZabbixAPISubClass(self, dict({\"prefix\": \"image\"}, **kwargs))
        self.mediatype = ZabbixAPISubClass(self, dict({\"prefix\": \"mediatype\"}, **kwargs))
        self.service = ZabbixAPISubClass(self, dict({\"prefix\": \"service\"}, **kwargs))
        self.templatescreen = ZabbixAPISubClass(self, dict({\"prefix\": \"templatescreen\"}, **kwargs))
        self.usermedia = ZabbixAPISubClass(self, dict({\"prefix\": \"usermedia\"}, **kwargs))
        self.hostinterface = ZabbixAPISubClass(self, dict({\"prefix\": \"hostinterface\"}, **kwargs))
        self.triggerprototype = ZabbixAPISubClass(self, dict({\"prefix\": \"triggerprototype\"}, **kwargs))
        self.graphprototype = ZabbixAPISubClass(self, dict({\"prefix\": \"graphprototype\"}, **kwargs))
        self.itemprototype = ZabbixAPISubClass(self, dict({\"prefix\": \"itemprototype\"}, **kwargs))
        self.webcheck = ZabbixAPISubClass(self, dict({\"prefix\": \"webcheck\"}, **kwargs))
        self.id = 0
        self.r_query = deque([], maxlen=r_query_len)
        self.debug(logging.INFO, \"url: \" + self.url)
 
    def _setuplogging(self):
        self.logger = logging.getLogger(\"zabbix_api.%s\" % self.__class__.__name__)
 
    def set_log_level(self, level):
        self.debug(logging.INFO, \"Set logging level to %d\" % level)
        self.logger.setLevel(level)
 
    def recent_query(self):
        \"\"\"
        return recent query
        \"\"\"
        return list(self.r_query)
 
    def debug(self, level, var=\"\", msg=None):
        strval = str(level) + \": \"
        if msg:
            strval = strval + str(msg)
        if var != \"\":
            strval = strval + str(var)
 
        self.logger.log(level, strval)
 
    def json_obj(self, method, params={}):
        obj = {'jsonrpc': '2.0',
               'method': method,
               'params': params,
               'auth': self.auth,
               'id': self.id
              }
 
        self.debug(logging.DEBUG, \"json_obj: \" + str(obj))
 
        return json.dumps(obj)
 
    def login(self, user='', password='', save=True):
        if user != '':
            l_user = user
            l_password = password
 
            if save:
                self.__username__ = user
                self.__password__ = password
        elif self.__username__ != '':
            l_user = self.__username__
            l_password = self.__password__
        else:
            raise ZabbixAPIException(\"No authentication information available.\")
 
        # don't print the raw password.
        hashed_pw_string = \"md5(\" + hashlib.md5(l_password.encode('utf-8')).hexdigest() + \")\"
        self.debug(logging.DEBUG, \"Trying to login with %s:%s\" % \
                (repr(l_user), repr(hashed_pw_string)))
        obj = self.json_obj('user.authenticate', {'user': l_user,
                'password': l_password})
        result = self.do_request(obj)
        self.auth = result['result']
 
    def test_login(self):
        if self.auth != '':
            obj = self.json_obj('user.checkAuthentication', {'sessionid': self.auth})
            result = self.do_request(obj)
 
            if not result['result']:
                self.auth = ''
                return False  # auth hash bad
            return True  # auth hash good
        else:
            return False
 
    def do_request(self, json_obj):
        headers = {'Content-Type': 'application/json-rpc',
                   'User-Agent': 'python/zabbix_api'}
 
        if self.httpuser:
            self.debug(logging.INFO, \"HTTP Auth enabled\")
            auth = 'Basic ' + string.strip(base64.encodestring(self.httpuser + ':' + self.httppasswd))
            headers['Authorization'] = auth
        self.r_query.append(str(json_obj))
        self.debug(logging.INFO, \"Sending: \" + str(json_obj))
        self.debug(logging.DEBUG, \"Sending headers: \" + str(headers))
 
        request = urllib2.Request(url=self.url, data=json_obj.encode('utf-8'), headers=headers)
        if self.proto == \"https\":
            https_handler = urllib2.HTTPSHandler(debuglevel=0)
            opener = urllib2.build_opener(https_handler)
        elif self.proto == \"http\":
            http_handler = urllib2.HTTPHandler(debuglevel=0)
            opener = urllib2.build_opener(http_handler)
        else:
            raise ZabbixAPIException(\"Unknow protocol %s\" % self.proto)
 
        urllib2.install_opener(opener)
        try:
            response = opener.open(request, timeout=self.timeout)
        except Exception as e:
            raise ZabbixAPIException(\"Site needs HTTP authentication. Error: \"+str(e))
        self.debug(logging.INFO, \"Response Code: \" + str(response.code))
 
        # NOTE: Getting a 412 response code means the headers are not in the
        # list of allowed headers.
        if response.code != 200:
            raise ZabbixAPIException(\"HTTP ERROR %s: %s\"
                    % (response.status, response.reason))
        reads = response.read()
        if len(reads) == 0:
            raise ZabbixAPIException(\"Received zero answer\")
        try:
            jobj = json.loads(reads.decode('utf-8'))
        except ValueError as msg:
            print (\"unable to decode. returned string: %s\" % reads)
            sys.exit(-1)
        self.debug(logging.DEBUG, \"Response Body: \" + str(jobj))
 
        self.id += 1
 
        if 'error' in jobj:  # some exception
            msg = \"Error %s: %s, %s while sending %s\" % (jobj['error']['code'],
                    jobj['error']['message'], jobj['error']['data'], str(json_obj))
            if re.search(\".*already\sexists.*\", jobj[\"error\"][\"data\"], re.I):  # already exists
                raise Already_Exists(msg, jobj['error']['code'])
            else:
                raise ZabbixAPIException(msg, jobj['error']['code'])
        return jobj
 
    def logged_in(self):
        if self.auth != '':
            return True
        return False
 
    def api_version(self, **options):
        self.__checkauth__()
        obj = self.do_request(self.json_obj('APIInfo.version', options))
        return obj['result']
 
    def __checkauth__(self):
        if not self.logged_in():
            raise ZabbixAPIException(\"Not logged in.\")
 
 
class ZabbixAPISubClass(ZabbixAPI):
    \"\"\" wrapper class to ensure all calls go through the parent object \"\"\"
    parent = None
    data = None
 
    def __init__(self, parent, data, **kwargs):
        self._setuplogging()
        self.debug(logging.INFO, \"Creating %s\" % self.__class__.__name__)
        self.data = data
        self.parent = parent
 
        # Save any extra info passed in
        for key, val in kwargs.items():
            setattr(self, key, val)
            self.debug(logging.WARNING, \"Set %s:%s\" % (repr(key), repr(val)))
 
    def __getattr__(self, name):
        if self.data[\"prefix\"] == \"configuration\" and name == \"import_\":  # workaround for \"import\" method
            name = \"import\"
 
        def method(*opts):
            return self.universal(\"%s.%s\" % (self.data[\"prefix\"], name), opts[0])
        return method
 
    def __checkauth__(self):
        self.parent.__checkauth__()
 
    def do_request(self, req):
        return self.parent.do_request(req)
 
    def json_obj(self, method, param):
        return self.parent.json_obj(method, param)
 
    @dojson2
    @checkauth
    def universal(self, **opts):
        return opts
" > /usr/lib/zabbix/externalscripts/zabbix_api.py

# Adequando acessos

chown zabbix:zabbix /usr/lib/zabbix/externalscripts/ -Rf
chmod 775 /usr/lib/zabbix/externalscripts/* -Rf


# FIM ---------------------------------------------------------------

# -------------------------------------------------------------------
# Mensagem de finalização

clear

echo -e "
 #########################################################	
#                  PROCESSO FINALIZADO                    #
 ---------------------------------------------------------
#                                                         #
# Aparentemente terminamos o processo de instalação!      #
# Agora, acesse o seu servidor externamente a partir      #
# de um web browser:                                      #
#                                                         #
# HTTP://IP_SERVIDOR/zabbix                               #
# HTTP://IP_SERVIDOR/glpi                                 #
#                                                         #
# Abaixo serão exibidos os possíveis endereços deste      #
# servidor:                                               #
 ---------------------------------------------------------
|                http://www.pillares.net                  |
 ---------------------------------------------------------
 IPs deste Servidor:
"
hostname -I | tr ' ' '\n'
