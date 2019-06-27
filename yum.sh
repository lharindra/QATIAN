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
echo -e "**********************"
echo -e "** Patching started **"
echo -e "**********************"
echo -e ""
do
    echo -e "Now patching the host ${host}"
    echo -e ""
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'yum_confirm' 2> /dev/null
    sudo su -
    hostname=$( hostname)
    yum check-update > /tmp/QAT/Yum_${hostname}
    if [[ $? -eq 100 ]]
    then
     echo "ERROR:- System has Security system patches. Please go ahead and patch them(if required)"
    fi
    yum check-update > /dev/null
    if [[ $? -eq 0 ]]
    then
     echo -e "Great stuff!! No patches to install"
    fi
    yum check-update > /dev/null
    if [[ $? -ne 0 && $? -ne 100 ]]
    then
     echo -e "ERROR:- Yum has some issue while checking the patches, Please check manually"
    fi
    sleep 3
yum_confirm
    echo -e "************"
    echo -e "** NOTE:- ** :- If the above output says \"System has Security system patches\" then procced saying(y) and patch. If not you can just say(n)"
    echo -e "************"
    echo -e ""
    read -p "Please check the defects list mentioned above to confirm whether to procced or not [y/n]:- " ny
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
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'yum_after' 2> /dev/null
      sudo su -
      hostname=$( hostname)
      host=$( hostname)
      yum check-update > /dev/null
      if [[ $? -eq 0 ]]
      then
       echo -e "Great stuff!! No patches to install"
      fi
      yum check-update > /tmp/QAT/Yum_${hostname}
      if [[ $? -eq 100 ]]
      then
       yum update -y 2> /dev/null
       if [[ $? -eq 0 ]]
       then
        echo -e "Patching is completed successfully"
       else
        echo -e "ERROR:- YUM has some issues while patching"
       fi
      fi
      yum check-update > /dev/null
      if [[ $? -ne 0 && $? -ne 100 ]]
      then
         echo -e "ERROR:- Yum has some issue while checking the patches, Please check manually"
      fi
      sleep 3
      echo -e "Patching completed on the host ${host}"
      echo -e ""
yum_after
      sleep 3 
      echo 
done
