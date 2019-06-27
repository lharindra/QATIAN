le getopts h:t:u: option
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
echo -e "Rebooting action is into the action"
echo -e ""
do
	echo -e "Now Rebooting $host.."
	echo -e ""
	#ibmssh -i $task_number $user@$host <<'reboot_before'
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'reboot_before'
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
	#ibmssh -i $task_number $user@$host <<'reboot_after'
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'reboot_after'
	     sleep 10
	     ps -ef >> /tmp/startups_1
	     df -h >> /tmp/mounts_1
	     cmp /tmp/mounts /tmp/mounts_1
	     if [[ $? -ne 0 ]]
	     then
	      echo -e "***********"
	      echo -e "** ERROR ** :- some file system had not mountes after rebooting the host. Please go and check them manually"
	      echo -e "***********"
	     fi
	     uptime=$( uptime)
	     echo -e ""
	     echo -e "++++++++++"
	     echo -e "X UPTIME X :------- ${uptime}"
	     echo -e "++++++++++"
	     echo -e ""
reboot_after
	echo -e "Successfully rebooted the $host"
done
echo -e ""
echo -e "Intrusive Testing is Successfully completed on $hosts :) "


