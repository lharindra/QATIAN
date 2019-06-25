#!/bin/bash
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
cpu=$( cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l) 2> /dev/null
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
echo -e "Display all the users configured on the host"
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
