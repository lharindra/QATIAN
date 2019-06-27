#!/bin/bash
while getopts h:t:u: option
do
case "${option}"
in
t) task_number=${OPTARG};;
h) hosts=${OPTARG};;
u) user=${OPTARG};;
esac
done
if [[ -z $user ]]
then
 user=iuxu
fi
IFS=","
for host in $hosts
echo -e "***************************"
echo -e "** Displaying the varlog **"
echo -e "***************************"
echo -e ""
do
	echo "varlog's found on the host ${host} "
	echo -e ""
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'varlog' 2> /dev/null
	sudo su -
	hostname=$( hostname)
	awk -v d1="$(date --date="-2880 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i error > /tmp/QAT/error_${hostname}.log
	if [[ $(wc -l < /tmp/QAT/error_${hostname}.log) -eq 0 ]]
	then
	 echo -e "No ERORS found under /var/log/messages" #please don't edit the typo ERORS(to exclude from the fileter we made a typo)
	 rm -rf /tmp/QAT/error_${hostname}.log
	else
	 echo -e "ERROR:- Still there are some ERROR logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog_${hostname}.log"
	fi
	awk -v d1="$(date --date="-2880 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i warning > /tmp/QAT/warning_${hostname}.log
	if [[ $(wc -l < /tmp/QAT/warning_${hostname}.log) -eq 0 ]]
	then
	 echo -e "No WARNINGS found under /var/log/messages"
	 rm -rf /tmp/QAT/warning_${hostname}.log
	else
	 echo -e "ERROR:- Still there are some WARNINGS logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog_${hostname}.log"
	fi
	awk -v d1="$(date --date="-2880 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i failed > /tmp/QAT/failed_${hostname}.log
	if [[ $(wc -l < /tmp/QAT/failed_${hostname}.log) -eq 0 ]]
	then
	 echo -e "No FAILED found under /var/log/messages"
	 rm -rf /tmp/QAT/failed_${hostname}.log
	else
	 echo -e "ERROR:- Still there are some FAIL logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog_${hostname}.log"
	fi
	awk -v d1="$(date --date="-2880 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i critical > /tmp/QAT/critical_${hostname}.log
	if [[ $(wc -l < /tmp/QAT/critical_${hostname}.log) -eq 0 ]]
	then
	 echo -e "No ERRORS found under /var/log/messages"
	 rm -rf /tmp/QAT/critical_${hostname}.log
	else
	 echo -e "ERROR:- Still there are some CRITICAL logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog_${hostname}.log"
	fi
	if [[ -f /tmp/QAT/varlog_${hostname}.log ]]
	then
	 cp /dev/null /tmp/QAT/varlog_${hostname}.log
	 echo -e "This was created on [$(date)]" >> /tmp/QAT/varlog_${hostname}.log
	fi
	if [[ -f /tmp/QAT/error_${hostname}.log ]]
	then
	 echo -e "++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "X ERROR LOGS X" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 cat /tmp/QAT/error_${hostname}.log >> /tmp/QAT/varlog_${hostname}.log
	 rm -rf /tmp/QAT/error_${hostname}.log
	fi
	if [[ -f /tmp/QAT/warning_${hostname}.log ]]
	then 
	 echo -e "++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "X WARNING LOGS X" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 cat /tmp/QAT/warning_${hostname}.log >> /tmp/QAT/varlog_${hostname}.log
	 rm -rf /tmp/QAT/warning_${hostname}.log
	fi
	if [[ -f /tmp/QAT/failed_${hostname}.log ]]
	then 
	 echo -e "+++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "X FAIL LOGS X" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "+++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 cat /tmp/QAT/failed_${hostname}.log >> /tmp/QAT/varlog_${hostname}.log
	 rm -rf /tmp/QAT/failed_${hostname}.log
	fi
	if [[ -f /tmp/QAT/critical_${hostname}.log ]]
	then
	 echo -e "+++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "X CRITICAL LOGS X" >> /tmp/QAT/varlog_${hostname}.log
	 echo -e "+++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
	 cat /tmp/QAT/critical_${hostname}.log >> /tmp/QAT/varlog_${hostname}.log
	 rm -rf /tmp/QAT/critical_${hostname}.log
	fi
	echo -e ""
	echo -e "End of the file +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo -e ""
varlog
done


