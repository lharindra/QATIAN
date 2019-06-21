#!/bin/bash
echo -e "" 
echo -e ""

echo -e "To verify the hostname and the OS version"
echo -e "-----------------------------------------"
hostname=$( hostname)
echo -e "Hostname:- ${hostname}"
File=/etc/redhat-release
if [ -f $File ]
then
  OS_Version=$( cat /etc/redhat-release)
  echo -e "The OS installed on Host is -- ${OS_Version}"
else
  OS_Version=$( cat /etc/oracle-release)
  echo -e "The OS installed on Host is -- ${OS_Version}"
fi
echo -e ""

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
echo -e "The mounts on the host"
echo -e "----------------------"
df -h --total
echo -e "The pysical volumns configured on the host"
pvs
echo -e "The volumns which are configured on the host"
vgs
echo -e "The logical storage configured on the host"
lvs
echo -e "-------------------------------------------"
if rpm -q BESAgent.x86_64
then
 Ver=$( rpm -q BESAgent.x86_64 | cut -d"-" -f2)
 echo -e "BigFix is installed with the version of:- ${Ver}"
fi
state=$( ps -C besclient >/dev/null && echo "Running" || echo "Not running")
echo -e "The besclient process on the host is:- ${state}"
Code=$( cat /var/opt/BESClient/besclient.config | egrep -C 2 'C_Code|__RelayServer1|__RelayServer2')
echo -e "RelaySevers ip's and c_code configured on the host"
echo -e ${Code}
echo -e "-------------------------------------------"
echo -e "To check the taddm files configured on the host"
ls -l /etc/sudoers.d/217_TADDMDISC_NA
if [[$? -ne 0 ]]
then
 echo -e "ERROR:- 217_TADDMDISC_NA is not configured on the host"
fi
ID=$( id taddmlux)
if [[$? -ne 0 ]]
then
 echo -e "ERROR:- No taddmlux user on the host"
fi
echo -e "The ID of the taddmlux is:- ${ID}"
ls -l ~taddmlux/.ssh/
if [[$? -ne 0 ]]
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
echo -e "-------------------------------------------"
echo -e "Display all the users configured on the host"
more /etc/passwd
echo -e "-------------------------------------------"
echo -e "Verify no User except root with UID 0"
more /etc/passwd | grep "x:0"
echo -e "-------------------------------------------"
echo -e "Verify no Group except root with GID 0"
more /etc/group | grep "x:0"
echo -e "-------------------------------------------"
echo -e "Verify whether FTP/Telnet are disabled"
ftp=$( ps -C ftp >/dev/null && echo "Running" || echo "Not running")
if [[ ${ftp} -eq "Running"]]
then
 echo -e "ERROR:- FTP on this host is enabled"
else
 echo -e "FTP is Disabled on the host"
fi
telnet=$( ps -C telnet >/dev/null && echo "Running" || echo "Not running")
if [[ ${telnet} -eq "Running"]]
then 
 echo -e "ERROR:- Telnet on this host is enabled"
else
 echo -e "Telnet is Disabled on the host"
fi
echo -e "-------------------------------------------"
echo -e "Verify SUDO users configured as necessary per External customer specific servers"
cat /etc/sudoers | grep -v '#'
echo -e "-------------------------------------------"
echo -e "Verify Linux firewall is "off" and in "accept" mod"
iptables -nL
echo -e "-------------------------------------------"
check=$( find /usr/bin/su /usr/bin/crontab -user root -perm -4000 -exec ls -ldb {} \;)
if [[ $? -eq 0 ]]
then
 echo -e "Both Crontab and SU files had SETUID enabled"
else
 echo -e "ERROR:- Both Crontab and SU files had SETUID is not enabled"
fi
echo -e "-------------------------------------------"
cp /etc/syslog.conf /etc/syslog.conf_"$(date +'%Y%m%d')"
if [[ $? -eq 0 ]]
then
 echo -e "Copied the syslog.conf file with latest date under /etc/"
else
 echo -e "ERROR:- Unable to copy the syslog.conf file(May be file does not exists)"
fi
echo -e "-------------------------------------------"
lookup=$( nslookup ibm.com)
if [[ $? -eq 0 ]]
then
 echo -e "Nslookup is working good!!! able to reach IBM.com" 
else
 echo -e "ERROR:- Unable to nslookup IBM.COM!!)"
fi






echo -e "
