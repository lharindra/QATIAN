#!/bin/bash
yum check-update > /tmp/QAT/Yum_${hostname}
if [[ $? -eq 100 ]]
then
 echo "System has Security system patches. Please go ahead and patch them(if required)"
 sleep 2
 while true; do
    read -p "Do you wish to install all the available patches? Please give the input(y/n):-" yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]
    then
     read -p "Re-Confirm please type(y/n):-" yn
    fi
    case $yn in
        [Yy]* ) yum update -y 2> /dev/null ; if [[ $? -eq 0 ]]; then echo -e "Patching is completed successfully"; else echo -e "ERROR:- YUM has some issues while patching"; fi; break;;
        [Nn]* ) echo -e "As you had selected (No) it's quiting!!!"; echo -e "ERROR:- Updates are available on the host"; break;;
        * ) echo "Please answer yes or no.";;
    esac
 done
elif [[ $? -eq 0 ]]
then
 echo -e "Great stuff!! No patches to install"
else
 echo -e "Error:- Something is bad with yum please check manually"
fi
sleep 3

