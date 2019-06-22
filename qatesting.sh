#!/bin/bash
echo -e "" 
echo -e ""

echo -e "To verify the hostname and the OS version"
echo -e "-----------------------------------------"
hostname=$( hostname)
echo -e "Hostname:- ${hostname}"
Name=$( cat /etc/os-release | sed -n '1p'|cut -d"=" -f2)
Version_id=$( cat /etc/os-release | sed -n '2p'|cut -d"=" -f2)
echo -e "the OS installed on The host is ${Name} with the version of ${Version_id}"
echo -e "-------------------------------------------"
Mem=$( free -tm| awk '{print  $1, $2}'| sed -n '2,4p' | tr "\n" " ")
echo -e "Available memory on the host is(MB's):- ${Mem}"
echo -e ""
echo -e "-------------------------------------------"
cpu=$( cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
core=$( cat /proc/cpuinfo | grep "cpu cores" | uniq |awk '{print $4}')
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
echo -e "-------------------------------------------"
if rpm -q BESAgent.x86_64
then
 Ver=$( rpm -q BESAgent.x86_64 | cut -d"-" -f2)
 echo -e "BigFix is installed with the version of:- ${Ver}"
else
 echo -e "ERROR:- BigFix is not installed on the host"
fi
state=$( ps -C besclient >/dev/null && echo "Running" || echo "Not running")
echo -e "the besclient process on The host is:- ${state}"
Code=$( cat /var/opt/BESClient/besclient.config | egrep -C 2 'C_Code|__RelayServer1|__RelayServer2')
echo -e "RelaySevers ip's and c_code configured on the host"
echo -e ${Code}
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
echo -e "-------------------------------------------"
echo -e "Check whether RSA is intalled on the host"
locate acestatus 2> /dev/null
if [[ $? -eq 0 ]]
then 
 echo -e "RSA is installed on the host"
else
 echo -e "ERROR:- RSA is not installed on the host"
fi
echo -e "-------------------------------------------"
echo -e "Display all the users configured on the host"
more /etc/passwd
echo -e "-------------------------------------------"
more /etc/passwd | grep "x:0" > /tmp/User_${hostname}
if [[ $(wc -l < /tmp/User_${hostname}) -ge 2 ]]
then
 echo -e "ERROR:- Some users have same permissions as root. Please find them below"
 cat /tmp/User_${hostname}
else
 echo -e "No User except root with UID 0"
 rm -rf /tmp/User_${hostname}
fi
echo -e "-------------------------------------------"
more /etc/group | grep "x:0" > /tmp/Group_${hostname}
if [[ $(wc -l < /tmp/Group_${hostname}) -ge 2 ]]
then
 echo -e "ERROR:- Some users have same permissions as root. Please find them below"
 cat /tmp/Group_${hostname}
else
 echo -e "No User except root with UID 0"
 rm -rf /tmp/Group_${hostname}
fi
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
echo -e "-------------------------------------------"
echo -e "Verify SUDO users configured as necessary per External customer specific servers"
cat /etc/sudoers | grep -v "#" | sed  '/^#/ d' | sed '/^Defaults/ d'|sed '/^$/d' > /tmp/Sudo_${hostname}
cat /tmp/Sudo_${hostname}
echo -e "-------------------------------------------"
echo -e "Verify Linux firewall is "off" and in "accept" mod"
iptables -nL 
echo -e "-------------------------------------------"
find /usr/bin/su /usr/bin/crontab -user root -perm -4000 -exec ls -ldb {} \; > /dev/null
if [[ $? -eq 0 ]]
then
 echo -e "Both Crontab and SU files had SETUID enabled"
else
 echo -e "ERROR:- Both Crontab and SU files had SETUID is not enabled"
fi
echo -e "-------------------------------------------"
cp /etc/syslog.conf /etc/syslog.conf_"$(date +'%Y%m%d')" 2> /dev/null
if [[  $? -eq 0  ]]
then
 echo -e "Copied the syslog.conf file with latest date under /etc/"
else
 echo -e "ERROR:- Unable to copy the syslog.conf file(May be file does not exists)"
fi
echo -e "-------------------------------------------"
nslookup www.google.com > /dev/null
if [[  $? -eq 0 ]]
then
 echo -e "Nslookup is working good!!! able to reach IBM.com" 
else
 echo -e "ERROR:- Unable to nslookup GOOGLE.COM!!)"
fi
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
 echo -e "FIM is not installed or configured(check with McAfee team(If required))"
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
 echo -e "As the OS version on the host is ${OS_ver}. HIP's configuration is not required as per the QAT Requirements. For more details check with McAfee team(If required)"
fi
echo -e "-------------------------------------------"
yum check-update > /tmp/Yum_${hostname}
if [[ $? -eq 100 ]]
then
 echo -e "System has Security system patches. Please go ahead and patch them(if required)"
 while true; do
    read -p "Do you wish to install all the available patches? Please give the input(y/n):-" yn
    case $yn in
        [Yy]* ) yum update -y; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
 done
elif [[ $? -eq 0 ]]
then
 echo -e "Great stuff!! No patches to install"
else
 echo -e "Error:- Something is bad with yum please check manually"
fi
echo -e "-------------------------------------------"
echo -e "Assure that Anti-virus is setup correctly and functioning"
rpm -q MFEcma
rpm -qa McAfeeVSEForLinux
/opt/NAI/LinuxShield/bin/nails --version
/opt/NAI/LinuxShield/bin/nails on-access --status
ps -ef | grep -i isec
/opt/isec/ens/threatprevention/bin/isecav --version
echo -e "-------------------------------------------"
echo -e "Healthchecks"


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
 echo -e "Netbackup software is not installed"
fi


echo -e "-------------------------------------------"





echo -e ""
