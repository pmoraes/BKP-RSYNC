##################################################
#### Desenvolvido por Cristian M. Caetano#########
#### DATA: 09/05/2016 ############################
####EMAIL: cristiancaetano@gmail.com#############
#################################################

#OBS: para funcionar corretamente devera criar um arquivo com o nome 'PASTA' e deixar no mesmo diretorio do script e mudar o caminho da variavel ARQUIVO dentro da funçao @BACKUPPASTAS


#!/bin/bash

INICIO=`date +%d/%m/%Y-%H:%M:%S`
LOG=/var/log/`date +%Y-%m-%d`_BKP_DIARIO.txt
PBACKUP=/diretorio/BKPDIARIO #Pasta onde sera colocadao o backup antes da sincronização
DATA=`date +%d-%b-%Y`
HORAAT=`date +%H:%M`
#HORA= `date +%H:%M:%S`

# FUNCAO CRIA PASTA DIARIA Com a 

	function @CRIAPASTADIARIA () {
		mkdir -p /Diretorio/BKPDIARIO/$DATA 
		}

# FUNCAO HORA
        function @HORA () {
                HORA=`date +%H:%M`
                }


#FUNCAO COMPACTA PASTAS
 	function @BACKUPPASTAS () {

                ARQUIVO="/diretorio/PASTA"

                for PASTA in `cat $ARQUIVO`; do

                        LOCAL=`echo $PASTA |awk -F / {'print $NF'}`

                        echo "" >> $LOG
                        echo " Efetuando Backup da pasta $PASTA" >> $LOG
                        echo "" >> $LOG

                        tar -czf $PBACKUP/$DATA/$LOCAL.tar.gz $PASTA
			echo "Escrevendo backup diario em $PBACKUP" >> $LOG
                done;
		
                }


#FUNCAO RODA RSYNC 

	function @RODARSYNC() {
		
		echo " " >> $LOG
		echo " " >> $LOG
		echo "|-----------------------------------------------" >> $LOG
		echo " Sincronização iniciada em $DATA $HORAAT" >> $LOG


		sudo rsync -Cravzp /Diretorio/BKPDIARIO   root@ipservidor:/mnt/backup/diretorio >> $LOG
		if [ $? = 0 ]; then  #Verifica se a sincronizaçao foi bem sucedida se ela foi bem entra no if se nao cai no else

			echo " Sincronização Finalizada em $DATA $HORAAT" >> $LOG
	                echo "|-----------------------------------------------" >> $LOG
        	        echo " " >> $LOG
                	echo " " >> $LOG
               		echo " deletando backups Locais de $PBACKUP $DATA $HORAAT" >> $LOG
                	echo "Backup Deletado com Sucesso de $PBACKUP" >> $LOG
                	echo "Enviando Email de informação para o Administrador" >> $LOG
                	echo "" >> $LOG
					@ENVIAEMAIL # chama a funçao envia email - Backup Sucedido com sucesso

                else
                        echo "Sincronização Mau concluida $DATA $HORAAT" >> $LOG
                        @ENVIAMAILPROBLEMA  # chama a funçao envia email - backup mau Sucedido
                fi


		rm -rf /DadosObra/BKPDIARIO/*

		}


#FUNCAO QUE ENVIA EMAIL PARA O ADMINISTRADOR
		function @ENVIAEMAIL () {

			EMAIL_FROM="remetente@email.com"
			EMAIL_TO="destinatario@email.com"

			SERVIDOR_SMTP="smtp.email.com:porta"
			SENHA=******

			ASSUNTO="$HOSTNAME - $1"
			MENSAGEM=$2

			if [ "$1" == "" ] ;then
			ASSUNTO="BKP DIARIO FEITO"
			fi
			if [ "$2" == "" ] ;then
			MENSAGEM="Backup Realizado com Sucesso  e Sincronizado Servidor de Arquivos"
			fi
			if [ "$3" != "" ] ;then
			MENSAGEM="$2 `cat $3`"
			fi

			sendemail -f $EMAIL_FROM -t $EMAIL_TO -u "$ASSUNTo" -m "$MENSAGEM" $ANEXO -a $LOG  -o tls=yes  -s $SERVIDOR_SMTP -xu $EMAIL_FROM -xp $SENHA
			echo "Email Enviador com Sucesso para $EMAIL_TO" >> $LOG
			echo " Deletando Arquivo de log do local" >> $LOG	
			rm -rf $LOG
			}


#FUNCAO QUE ENVIA EMAIL DE PROBLEMA CASO NÃO FOR FEITO O RSYNC COM SUCESSO
 		function @ENVIAMAILPROBLEMA () {

                EMAIL_FROM="remetente@email.com"
                EMAIL_TO="destinatario@email.com"

                SERVIDOR_SMTP="smtp.email.com:porta"
                SENHA=*******

                ASSUNTO="$HOSTNAME - $1"
                MENSAGEM=$2

                if [ "$1" == "" ] ;then
                ASSUNTO="BKP DIARIO FEITO"
                fi
                if [ "$2" == "" ] ;then
                MENSAGEM=" ERRO AO FAZER A SINCRONIZAÇÃO DOS DADOS - VERIFIQUE A CONDEXAO COM O SERVIDOR" >> $LOG
                fi
                if [ "$3" != "" ] ;then
                MENSAGEM="$2 `cat $3`"
                fi

                sendemail -f $EMAIL_FROM -t $EMAIL_TO -u "$ASSUNTo" -m "$MENSAGEM" $ANEXO -a $LOG  -o tls=yes  -s $SERVIDOR_SMTP -xu $EMAIL_FROM -xp $SENHA
				}




@CRIAPASTADIARIA
@BACKUPPASTAS
@RODARSYNC


