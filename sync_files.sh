#!/bin/sh

set -o pipefail

# Funcao: Sync directories and files between linux servers
#
# Author: Paulo Ricardo de Mello
# E-mail: paulo.mello@outlook.com

#############################################################################
# Test if server is IPv4 or IPv6 and set $source_server #
#############################################################################

ip=192.168.1.4

if echo $ip |grep ":" 1>>/dev/null 2>>/dev/null
	then
    	source_server="["$ip"]"
	else
		source_server="$ip"
fi

# Vars
parametros="-vrlcpog --delete"
arq_parametros="/usr/local/sbin/sync_files.par"
arq_parametros_exclude="/usr/local/sbin/sync_files_exclude.par"
log_execucao=/var/log/sync_files.log

erro=0;

TESTE_ERRO(){
  if [ $? != "0" ]
    then
      logger -p 1 "NOTICE - SYNC_FILE - Error in directory sync $b"
      echo "Error - error in sync for directory $b" 1>>$log_execucao 2>>$log_execucao
      erro=1
  fi
}

  # Verificar se não estamos no no ativo
  if ip -4 addr show |grep "$ip" |cut -f6 -d " " 1>>/dev/null 2>>/dev/null
    then
      logger -p 1 "NOTICE - SYNC_FILE - Replicacao esta executado no node ativo. Verificar com urgencia."
      echo "Node ativo. Replicacao cancelada."
      exit 1
  fi

  if ip -6 addr show |grep "$ip" |cut -f6 -d " " 1>>/dev/null 2>>/dev/null
    then
      logger -p 1 "NOTICE - SYNC_FILE - Replicacao esta executado no node ativo. Verificar com urgencia."
      echo "Node ativo. Replicacao cancelada."
      exit 1
  fi

  # Checa se existe sincronismo executando
  if ps -ef |grep rsync |grep -v grep 1>>/dev/null 2>>/dev/null
    then
      logger -p 1 "NOTICE - SYNC_FILE - Outro processo de replicacao esta ativo. Verificar janela de replicacao ou processo travado."
      echo "Outro processo de replicacao esta ativo. Verificar janela de replicacao ou processo travado."
      exit 1
  fi

  # Data
  date >> $log_execucao
  echo "Inicio da Execucao" >> $log_execucao

 for b in `cat $arq_parametros`
 do
   dest_dir=`echo $b | awk -F / '{if (NF==1) { NF}  else { NF-=1}} NF' | tr [:blank:] /`
   echo "Sincronizando Diretorio $b" 1>>$log_execucao 2>>$log_execucao
   date >> $log_execucao
   rsync $parametros --exclude-from=$arq_parametros_exclude "$source_server:/$b" "/$dest_dir" 1>>$log_execucao 2>>$log_execucao
   TESTE_ERRO
  echo >> $log_execucao
 done

 # Data
  date >> $log_execucao
  echo >> $log_execucao

 # Checa se houve erro na sincronizacao
 if [ $erro = "1" ]
  then
   exit 1
  else
   exit 0
 fi