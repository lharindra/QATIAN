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
export host=$host
export user=$user
export task=$user
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'qatesting' | tee /tmp/QAT/log_$host.log
sudo su -
mkdir -p /tmp/QAT
echo -e "+++++++++++++++++++++++++++++++++++++++"
echo -e "X QAT TESTING GOING TO BE STARTED !!! X"
echo -e "+++++++++++++++++++++++++++++++++++++++"
echo -e ""
echo -e "To verify the hostname and the OS version"
echo -e "-----------------------------------------"
hostname=$( hostname)
echo -e "Hostname:- ${hostname}"
Name=$( cat /etc/os-release | sed -n '1p'|cut -d"=" -f2) 2> /dev/null
Version_id=$( cat /etc/os-release | sed -n '2p'|cut -d"=" -f2) 2> /dev/null
echo -e "the OS installed on The host is ${Name} with the version of ${Version_id}"
sleep 3
echo -e "-------------------------------------------"
Mem=$( free -tm| awk '{print  $1, $2}'| sed -n '2,4p' | tr "\n" " ") 2> /dev/null
echo -e "Available memory on the host is(MB's):- ${Mem}"
echo -e "-------------------------------------------"
cpu=$( cat /proc/cpuinfo |grep "processor" |sort | uniq | wc -l) 2> /dev/null
core=$( cat /proc/cpuinfo | grep "cpu cores" | uniq |awk '{print $4}') 2> /dev/null
echo -e "No of CORE ${core} per No Of CPU ${cpu} on the Host -- In numerical format(core*cpu):- ${core}*${cpu}"
lscpu | sed -n '1,2p'
echo -e "-------------------------------------------"
echo -e "the mounts on The host"
echo -e "----------------------"
df -h --total
echo -e "the pysical volumns configured on The host"
pvs
echo -e "the volumns which are configured on The host"
vgs
echo -e "the logical storage configured on The host"
lvs
sleep 3
echo -e "-------------------------------------------"
salt_st=$( ps -C salt-minion >/dev/null && echo "Running" || echo "Not running")
if [[ $salt_st == "Running" ]]
then
 echo -e "Salt-minion is ${salt_st} on the host"
else
 echo -e "ERROR:- Salt-minion is ${salt_st} on the host"
fi
echo -e "-------------------------------------------"
if rpm -q BESAgent.x86_64
then
 Ver=$( rpm -q BESAgent.x86_64 | cut -d"-" -f2)
 echo -e "BigFix is installed with the version of:- ${Ver}"
else
 echo -e "ERROR:- BigFix is not installed on the host"
fi
bigfix_st=$( ps -C BESClient >/dev/null && echo "Running" || echo "Not running")
if [[ $bigfix_st == "Running" ]]
then
 echo -e "BigFix is ${bigfix_st} on the host"
else
 echo -e "ERROR:- BigFix is ${bigfix_st} on the host"
fi
C_code=$( cat /var/opt/BESClient/besclient.config | egrep -C 2 'C_Code|__RelayServer1|__RelayServer2' | sed -n 4p | awk '{print $3}')
echo -e "The value of the C_code is:- ${C_code}"
Relasyser1=$( cat /var/opt/BESClient/besclient.config | egrep -C 2 'C_Code|__RelayServer1|__RelayServer2' | sed -n 10p | awk '{print $3}')
echo -e "The value of the RelayServer1 is:- ${Relasyser1}"
Relasyser2=$( cat /var/opt/BESClient/besclient.config | egrep -C 2 'C_Code|__RelayServer1|__RelayServer2' | sed -n 13p | awk '{print $3}')
echo -e "The value of the RelayServer2 is:- ${Relasyser2}"
sleep 3
echo -e "-------------------------------------------"
echo -e "To check the taddm files configured on the host"
ls -l /etc/sudoers.d/217_TADDMDISC_NA 2> /dev/null
if [[ $? -ne 0 ]]
then
 echo -e "ERROR:- 217_TADDMDISC_NA is not configured on the host"
fi
ID=$( id taddmlux) 2> /dev/null
if [[ $? -ne 0 ]]
then
 echo -e "ERROR:- No taddmlux user on the host"
fi
echo -e "the ID of The taddmlux is:- ${ID}"
ls -l ~taddmlux/.ssh/ 2> /dev/null
if [[ $? -ne 0 ]]
then
 echo -e "ERROR:- No taddmlux .ssh file  on the host"
fi
sleep 3
echo -e "-------------------------------------------"
echo -e "Check whether RSA is intalled on the host"
locate acestatus 2> /dev/null
if [[ $? -eq 0 ]]
then 
 echo -e "RSA is installed on the host"
else
 echo -e "ERROR:- RSA is not installed on the host"
fi
sleep 3
echo -e "-------------------------------------------"
echo -e "Display all the users configured on the host"ec2-52-15-204-90.us-east-2.compute.amazonaws.com
cat /etc/passwd
echo -e "-------------------------------------------"
echo -e "Network configurations"
ipv4=$( hostname -I | awk '{print $1}')
echo -e "The IPv4 address configured on the host is:- ${ipv4}"
ip -6 addr | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^::1 | grep -v ^fe80 > /tmp/QAT/ipv6_${hostname}
if [[ ! -s /tmp/QAT/ipv6_$hostname ]]
then
 echo -e "IPv6 is not configured on the host"
else
 echo -e "ERROR:- IPv6 is configured on the host and here they are ..."
 cat /tmp/QAT/ipv6_{hostname}
fi
echo -e "the default gateway configured on the host"
netstat -rn
sleep 3
echo -e "-------------------------------------------"
cat /etc/passwd | grep "x:0" > /tmp/QAT/User_${hostname}
if [[ $(wc -l < /tmp/QAT/User_${hostname}) -ge 2 ]]
then
 echo -e "ERROR:- Some users have same permissions as root. Please find them below"
 cat /tmp/QAT/User_${hostname}
else
 echo -e "No User except root with UID 0"
 rm -rf /tmp/QAT/User_${hostname}
fi
sleep 3
echo -e "-------------------------------------------"
cat /etc/group | grep "x:0" > /tmp/QAT/Group_${hostname}
if [[ $(wc -l < /tmp/QAT/Group_${hostname}) -ge 2 ]]
then
 echo -e "ERROR:- Some users have same permissions as root. Please find them below"
 cat /tmp/QAT/Group_${hostname}
else
 echo -e "No User except root with GID 0"
 rm -rf /tmp/QAT/Group_${hostname}
fi
sleep 3
echo -e "-------------------------------------------"
echo -e "Verify whether FTP/Telnet are disabled"
ps -C ftp > /dev/null 
if [[ $? -eq 0 ]]
then
 echo -e "ERROR:- FTP on this host is enabled"
else
 echo -e "FTP is Disabled on the host"
fi
ps -C telnet > /dev/null
if [[ $? -eq 0 ]]
then 
 echo -e "ERROR:- Telnet on this host is enabled"
else
 echo -e "Telnet is Disabled on the host"
fi
sleep 3
echo -e "-------------------------------------------"
echo -e "Verify SUDO users configured as necessary per External customer specific servers"
cat /etc/sudoers | grep -v "#" | sed  '/^#/ d' | sed '/^Defaults/ d'|sed '/^$/d' > /tmp/QAT/Sudo_${hostname}
cat /tmp/QAT/Sudo_${hostname}
echo -e "-------------------------------------------"
echo -e "Verify Linux firewall is "off" and in "accept" mod"
iptables -nL > tables 2> /dev/null
status=$( cat tables | awk '{print $5}' | sed '/^$/d' | uniq -d)
if [[ $(wc -l < tables) -eq 8 && $status -eq "destination" ]]
then
 echo "No extra Firewall rules are configured(It has default configuration)"
else
 echo -e "ERROR:- Some extra firewall rules are configured on the host(please have a look)"
fi
sleep 3
echo -e "-------------------------------------------"
find /usr/bin/su /usr/bin/crontab -user root -perm -4000 -exec ls -ldb {} \; > /dev/null
if [[ $? -eq 0 ]]
then
 echo -e "Both Crontab and SU files had SETUID enabled"
else
 echo -e "ERROR:- Both Crontab and SU files had SETUID is not enabled"
fi
sleep 3
echo -e "-------------------------------------------"
cp /etc/rsyslog.conf /etc/rsyslog.conf_"$(date +'%Y%m%d')" 2> /dev/null
if [[  $? -eq 0  ]]
then
 echo -e "Copied the rsyslog.conf file with latest date under /etc/rsyslog.conf_(yymmdd)"
else
 echo -e "ERROR:- Unable to copy the rsyslog.conf file(May be file does not exists)"
fi
sleep 3
echo -e "-------------------------------------------"
nslookup www.google.com > /dev/null
if [[  $? -eq 0 ]]
then
 echo -e "Nslookup is working good!!! able to reach IBM.com" 
else
 echo -e "ERROR:- Unable to nslookup GOOGLE.COM!!)"
fi
sleep 3
echo -e "-------------------------------------------"
echo -e "Verify whether ncpa is running"
nagio_st=$( ps -C ncpa_passive >/dev/null && echo "Running" || echo "Not running")
if [[ nagio_st == "Running" ]]
then
 echo -e "Nagios is ${nagio_st} on the host"
else
 echo -e "ERROR:- Nagios is ${nagio_st} on the host"
fi
parent=$( /usr/local/ncpa/etc/ncpa.cfg | grep -i parent | grep -v "#")
echo -e "The URL congifured for is(/usr/local/ncpa/etc/ncpa.cfg) :- ${parent}"
sleep 3
echo -e "-------------------------------------------"
sadmin status > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]
then
 status=$( sadmin status|sed -n '1,2p'| awk '{print $NF}'|uniq -d)
 if [[ -z ${status} ]]
 then
  echo -e "ERROR:- FIM is installed but one of the configuration is in Disabled state"
 else
  echo -e "FIM is configured and it is in:- ${state} state"
 fi
else
 echo -e "ERROR:- FIM is not installed or configured(check with McAfee team(If required))"
fi
OS_ver=$( cat /etc/os-release | sed -n '2p'|cut -d"=" -f2 | sed 's/^"//; s/"$//'| awk '{print $1}'|cut -d"." -f1)
if [[ "$OS_ver" -eq "6" ]]
then
 echo -e "As the OS version is ${OS_ver} HIP will be configured"
 rpm -qa | grep -i hip
 /opt/McAfee/hip/hipts status
 echo -e "To check the version(optional)"
 /opt/McAfee/agent/bin/./cmdagent -i
else
 echo -e "ERROR:- As the OS version on the host is ${OS_ver}. HIP's configuration is not required as per the QAT Requirements. For more details check with McAfee team(If required)"
fi
sleep 3
echo -e "-------------------------------------------"
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
echo -e "-------------------------------------------"
echo -e "Assure that Anti-virus is setup correctly and functioning"
isec_st=$( ps -C isectpd >/dev/null && echo "Running" || echo "Not running")
if [[ isec_st == "Running" ]]
then
 echo -e "Anti-virus is ${isec_st} on the host"
else
 echo -e "ERROR:- Anti-virus is ${isec_st} on the host"
fi
/opt/isec/ens/threatprevention/bin/isecav --version
sleep 3
echo -e "-------------------------------------------"
echo -e "Healthchecks"
echo -e "EP_CHECK testing -----------------------------------"
check_EP=$( ls -lt /var/tmp/IBM_SAC/EP_CHECK/ | grep -i pass | sed -n 1p | awk '{print $9}') 2> /dev/null
if [[ $? -ne 0 ]]
then
 echo -e "ERROR:- /var/tmp/IBM_SAC/EP_CHECK/ :- This folder is not configired "
elif [[ -z $check_EP ]]
then
 echo -e "ERROR:- There is no pass file under /var/tmp/IBM_SAC/EP_CHECK/"
else
 Validate_EP=$( find /var/tmp/IBM_SAC/EP_CHECK/${check_EP} -mtime +30 -exec echo "still valid" \;)
 if [[ -z $Validate_EP ]]
 then
  echo -e "ERROR:- The pass file had expired!! it's been more than 30 days since the last modification(Please re-run the health checks)"
 else
  echo -e "EP_CHECK healthcheck is Successfull"
 fi
fi
sleep 3
echo -e "SCHECK testing -----------------------------------"
check_SC=$( ls -lt /var/tmp/IBM_SAC/SCHECK/ | grep -i pass | sed -n 1p | awk '{print $9}') 2> /dev/null
if [[ $? -ne 0 ]]
then
 echo -e "ERROR:- /var/tmp/IBM_SAC/SCHECK/ :- This folder is not configired "
elif [[ -z $check_SC ]]
then
 echo -e "ERROR:- There is no pass file under /var/tmp/IBM_SAC/SCHECK/"
else
 Validate_SC=$( find /var/tmp/IBM_SAC/SCHECK/${check_SC} -mtime +30 -exec echo "still valid" \;)
 if [[ -z $Validate_SC ]]
 then
  echo -e "ERROR:- The pass file had expired!! it's been more than 30 days since the last modification(Please re-run the health checks)"
 else
  echo -e "EP_CHECK healthcheck is Successfull"
 fi
fi
sleep 3
echo -e "SSH_CHECK testing -----------------------------------"
check_SS=$( ls -lt /var/tmp/IBM_SAC/SSH_CHECK/ | grep -i pass | sed -n 1p | awk '{print $9}') 2> /dev/null
if [[ $? -ne 0 ]]
then
 echo -e "ERROR:- /var/tmp/IBM_SAC/SSH_CHECK/ :- This folder is not configired "
elif [[ -z $check_SS ]]
then
 echo -e "ERROR:- There is no pass file under /var/tmp/IBM_SAC/SSH_CHECK/"
else
 Validate_SS=$( find /var/tmp/IBM_SAC/SSH_CHECK/${check_SS} -mtime +30 -exec echo "still valid" \;)
 if [[ -z $Validate_SS ]]
 then
  echo -e "ERROR:- The pass file had expired!! it's been more than 30 days since the last modification(Please re-run the health checks)"
 else
  echo -e "EP_CHECK healthcheck is Successfull"
 fi
fi
sleep 3
echo -e "-------------------------------------------"
ballon=$( lsmod | grep balloon) 2> /dev/null
if [[ $? -eq 0 ]]
then
 echo -e "Balloon driver is configured on the host and here is the output:- ${ballon}"
else
 echo -e "ERROR:- Ballon driver is not installed on the host(Please check whether host is build in VmWare environment)"
fi
echo -e "-------------------------------------------"
echo -e "Netbackup settings"
Netback=$( cat /usr/openv/netbackup/bin/version)
if [[ $? -eq 0 ]]
then
 echo -e "Netbackup is installed with the version of ${Netback}"
else
 echo -e "ERROR:- Netbackup software is not installed"
fi
echo -e "----------------------The End---------------------"
echo -e ""
qatesting
echo -e "************************************************"
echo -e "** Here are the defect after testing the host **"
echo -e "************************************************"
cat /tmp/QAT/log_${host}.log | grep -i error | awk '{$1=""; print}' > /tmp/QAT/defects_${host}
if [[ $(wc -l < /tmp/QAT/defects_${host}) -eq 0 ]]
then
 echo -e "Great Stuff :) !!! not defects found on the host ${host}"
else
 echo -e "$(wc -l < /tmp/QAT/${host}_defects) defects are found while testing the host ${host} and they are......"
 cat -n /tmp/QAT/defects_${host}
fi 
echo -e "**************************************"
echo -e "** Patching Automation confirmation **"
echo -e "**************************************"
echo -e ""
echo -e "************"
echo -e "** NOTE:- ** Please check the defects list mentioned above to confirm whether to procced or not. IF no defects found"
echo -e "************ related to patching then you skip to the next section by giving(n). If you see there are patchs on host in defect enter(y) to proceed."
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
yum_after
  sleep 3
fi
sleep 3
echo -e ""
echo -e "***************************************"
echo -e "** Intrusive Automation confirmation **"
echo -e "***************************************"
echo -e ""
read -p "Do you want do intrusive(reboot), Please confirm[y/n]:- " yn
if [[ "$yn" == "n" || "$yn" == "N" ]]
then
 echo -e "Not performing the intrusive action on the host :( !!"
fi
if [[ "$yn" == "y" || "$yn" == "Y" ]]
then
     read -p "Re-Confirm please type(y/n):-" yn
fi
if [[ "$yn" == "y" || "$yn" == "Y" ]]
then
 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'reboot_before' 2> /dev/null
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
 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'reboot_after' 2> /dev/null
#ssh -t hari@ec2-18-216-189-30.us-east-2.compute.amazonaws.com <<'reboot_after'
     sleep 10
     ps -ef >> /tmp/startups_1
     df -h >> /tmp/mounts_1
     cmp /tmp/mounts /tmp/mounts_1
     if [[ $? -ne 0 ]]
     then
      echo -e "***********"
      echo -e "** ERROR **" :- some file system had not mountes after rebooting the host. Please go and check them manually
      echo -e "***********"
     fi
     uptime=$( uptime)
     echo -e ""
     echo -e "++++++++++"
     echo -e "X UPTIME X :------- ${uptime}"
     echo -e "++++++++++"
     echo -e ""
reboot_after
 echo -e "************************************"
 echo -e "** Successfully rebooted the host **"
 echo -e "************************************"
 echo -e ""
 echo -e ""
 echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++- XOX -+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 echo -e ""
 echo -e ""
 echo -e "************************************"
 echo -e "** LAST 48 HOURS EVENT LOG ERRORS **"
 echo -e "************************************"
 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@$host <<'varlog'
 sudo su -
 hostname=$( hostname)
 awk -v d1="$(date --date="-2880 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i error > /tmp/QAT/error_{hostname}.log
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
  echo -e "This was created on [$(date)]" > /tmp/QAT/varlog_${hostname}.log
 fi
 if [[ -f /tmp/QAT/error_${hostname}.log ]]
 then
  echo -e "++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "X ERROR LOGS X" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  cat /tmp/QAT/error.log >> /tmp/QAT/varlog_${hostname}.log
  rm -rf /tmp/QAT/error.log
 fi
 if [[ -f /tmp/QAT/warning_${hostname}.log ]]
 then 
  echo -e "++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "X WARNING LOGS X" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  cat /tmp/QAT/warning.log >> /tmp/QAT/varlog_${hostname}.log
  rm -rf /tmp/QAT/warning.log
 fi
 if [[ -f /tmp/QAT/failed.log ]]
 then 
  echo -e "+++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "X FAIL LOGS X" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "+++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  cat /tmp/QAT/failed.log >> /tmp/QAT/varlog_${hostname}.log
  rm -rf /tmp/QAT/failed.log
 fi
 if [[ -f /tmp/QAT/critical_${hostname}.log ]]
 then
  echo -e "+++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "X CRITICAL LOGS X" >> /tmp/QAT/varlog_${hostname}.log
  echo -e "+++++++++++++++++" >> /tmp/QAT/varlog_${hostname}.log
  cat /tmp/QAT/critical.log >> /tmp/QAT/varlog_${hostname}.log
  rm -rf /tmp/QAT/critical.log
 fi
 if [[ ! -s /tmp/QAT/varlog_${hostname}.log ]]
 then
  echo -e "Great stuff :) !!! No event log errors on the host"
 else
  echo -e "These are the event log errors found on the host"
  cat /tmp/QAT/varlog_${hostname}.log
 fi
varlog
fi
echo -e "*********************************************************************"
echo -e "** Done With Automation Testing For QAT Process!! Thanks For Using **"
echo -e "*********************************************************************"

