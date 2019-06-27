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
echo -e "Defecs on the hosts"
echo -e ""
do
	echo -e "The following are the defects found on the host ${host}"
	echo -e ""
	cat /tmp/QAT/log_${host}.log | grep -i error | awk '{$1=""; print}' > /tmp/QAT/defects_${host}
	if [[ $(wc -l < /tmp/QAT/defects_${host}) -eq 0 ]]
	then
	 echo -e "Great Stuff :) !!! not defects found on the host ${host}"
	else
	 echo -e "$(wc -l < /tmp/QAT/${host}_defects) defects are found while testing the host ${host} and they are......"
	 cat -n /tmp/QAT/defects_${host}
	fi
	echo -e ""
	echo -e ""
done

