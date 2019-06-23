#!/bin/bash
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i error > /tmp/error.log
if [[ $(wc -l < /tmp/error.log) -eq 0 ]]
then
 echo -e "No ERORS found under /var/log/messages" #please don't edit the typo ERORS(to exclude from the fileter we made a typo)
 rm -rf /tmp/error.log
else
 echo -e "ERROR:- Still there are some ERROR logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/error.log"
fi
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i warning > /tmp/warning.log
if [[ $(wc -l < /tmp/warning.log) -eq 0 ]]
then
 echo -e "No WARNINGS found under /var/log/messages"
 rm -rf /tmp/warning.log
else
 echo -e "ERROR:- Still there are some WARNINGS logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/warning.log"
fi
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i failed > /tmp/failed.log
if [[ $(wc -l < /tmp/failed.log) -eq 0 ]]
then
 echo -e "No FAILED found under /var/log/messages"
 rm -rf /tmp/failed.log
else
 echo -e "ERROR:- Still there are some FAIL logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/failed.log"
fi
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i critical > /tmp/critical.log
if [[ $(wc -l < /tmp/critical.log) -eq 0 ]]
then
 echo -e "No ERRORS found under /var/log/messages"
 rm -rf /tmp/critical.log
else
 echo -e "ERROR:- Still there are some CRITICAL logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/critical.log"
fi
if [[ -f /tmp/varlog.log ]]
then
 cp /dev/null /tmp/varlog.log
 echo -e "This was created on [$(date)]" >> /tmp/varlog.log
fi
if [[ -f /tmp/error.log ]]
then
 echo -e "++++++++++++++" >> /tmp/varlog.log
 echo -e "X ERROR LOGS X" >> /tmp/varlog.log
 echo -e "++++++++++++++" >> /tmp/varlog.log
 cat /tmp/error.log >> /tmp/varlog.log
 rm -rf /tmp/error.log
fi
if [[ -f /tmp/warning.log ]]
then 
 echo -e "++++++++++++++++" >> /tmp/varlog.log
 echo -e "X WARNING LOGS X" >> /tmp/varlog.log
 echo -e "++++++++++++++++" >> /tmp/varlog.log
 cat /tmp/warning.log >> /tmp/varlog.log
 rm -rf /tmp/warning.log
fi
if [[ -f /tmp/failed.log ]]
then 
 echo -e "+++++++++++++" >> /tmp/varlog.log
 echo -e "X FAIL LOGS X" >> /tmp/varlog.log
 echo -e "+++++++++++++" >> /tmp/varlog.log
 cat /tmp/failed.log >> /tmp/varlog.log
 rm -rf /tmp/failed.log
fi
if [[ -f /tmp/critical.log ]]
then
 echo -e "+++++++++++++++++" >> /tmp/varlog.log
 echo -e "X CRITICAL LOGS X" >> /tmp/varlog.log
 echo -e "+++++++++++++++++" >> /tmp/varlog.log
 cat /tmp/critical.log >> /tmp/varlog.log
 rm -rf /tmp/critical.log
fi
