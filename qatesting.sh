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
ID=$( id taddmlux)
echo -e "The ID of the taddmlux is:- ${ID}"
ls -l ~taddmlux/.ssh/
echo -e "-------------------------------------------"
