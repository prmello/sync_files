#!/bin/sh

set -o pipefail

# Funcao: Sync directories and files between linux servers in a active/passive cluster environment
#
# Author: Paulo Ricardo de Mello
# E-mail: paulo.mello@outlook.com

#############################################################################
# Test if server is IPv4 or IPv6 and set $source_server #
#############################################################################

ip=$1

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

  # Check if we are in the active node
  if ip -4 addr show |grep "$ip" |cut -f6 -d " " 1>>/dev/null 2>>/dev/null
    then
      logger -p 1 "NOTICE - SYNC_FILE - Replication are running in the active node. Check with urgency."
      echo "Active node. replication cancelled."
      exit 1
  fi

  if ip -6 addr show |grep "$ip" |cut -f6 -d " " 1>>/dev/null 2>>/dev/null
    then
      logger -p 1 "NOTICE - SYNC_FILE - Replication are running in the active node. Check with urgency."
      echo "Active node. replication cancelled."
      exit 1
  fi

  # Check if another replication process exist
  if ps -ef |grep rsync |grep -v grep 1>>/dev/null 2>>/dev/null
    then
      logger -p 1 "NOTICE - SYNC_FILE - Another replication process is active. Please verify the time schedule space or locked process."
      echo "Another replication process is active. Please verify the time schedule space or locked process."
      exit 1
  fi

  # Date
  date >> $log_execucao
  echo "Replication start..." >> $log_execucao

 for b in `cat $arq_parametros`
 do
   dest_dir=`echo $b | awk -F / '{if (NF==1) { NF}  else { NF-=1}} NF' | tr [:blank:] /`
   echo "Syncing dir $b" 1>>$log_execucao 2>>$log_execucao
   date >> $log_execucao
   rsync $parametros --exclude-from=$arq_parametros_exclude "$source_server:/$b" "/$dest_dir" 1>>$log_execucao 2>>$log_execucao
   TESTE_ERRO
  echo >> $log_execucao
 done

 # Date
  date >> $log_execucao
  echo >> $log_execucao

 # Error check
 if [ $erro = "1" ]
  then
   exit 1
  else
   exit 0
 fi