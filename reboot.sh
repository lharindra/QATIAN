#!/bin/bash
while getopts h:t:u: option
do
case "${option}"
in
t) task_number=${OPTARG};;
h) host=${OPTARG};;
u) user=${OPTARG};;
esac
done
if [[ -z $user ]]
then
 user=iuxu
fi
ibmssh -i $task_number $user@$host <<'reboot_before'
#ssh -t hari@ec2-18-216-189-30.us-east-2.compute.amazonaws.com <<'reboot_before'
sudo su -
ps -ef >> /tmp/startups
df -h >> /tmp/mounts
sudo -k reboot
reboot_before
sleep 10
printf "%s" "waiting for Server to Back Online ."
while ! timeout 2 ping -c 1 -n $host &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Server is back online"
sleep 10
ibmssh -i $task_number $user@$host <<'reboot_after'
#ssh -t hari@ec2-18-216-189-30.us-east-2.compute.amazonaws.com <<'reboot_after'
     sleep 10
     ps -ef >> /tmp/startups_1
     df -h >> /tmp/mounts_1
reboot_after
echo -e "Successfully rebooted the host"
