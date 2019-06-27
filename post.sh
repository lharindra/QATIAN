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
echo -e "*********************"
echo -e "** Removeing Files **"
echo -e "*********************"
echo -e ""
do
	echo -e "Now removing files on the host ${host}"
    echo -e ""
    read -p "Please confirm whether you want to delete all the testing files[y/n]" yn
    if [[ "$ny" == "n" || "$ny" == "N" ]]
    then
     echo -e "As you had selected (No) it's quiting!!! :( !!"
    fi
    if [[ "$ny" == "y" || "$ny" == "Y" ]]
    then
         read -p "Re-Confirm please type(y/n):-" ny
    fi
    if [[ "$ny" == "y" || "$ny" == "Y" ]]
    then
	    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'remove' 2> /dev/null
	    sudo su -
	    hostname=$( hostname)
	    rm -rf /tmp/QAT/*_${hostname}*
	    sleep 3
remove
	fi
        echo -e ""
	echo -e "Done!! removed all files from $host"
done
echo -e ""
echo -e "Done :)"
