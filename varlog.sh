#!/bin/bash
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i error > /tmp/QAT/error.log
if [[ $(wc -l < /tmp/QAT/error.log) -eq 0 ]]
then
 echo -e "No ERORS found under /var/log/messages" #please don't edit the typo ERORS(to exclude from the fileter we made a typo)
 rm -rf /tmp/QAT/error.log
else
 echo -e "ERROR:- Still there are some ERROR logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog.log"
fi
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i warning > /tmp/QAT/warning.log
if [[ $(wc -l < /tmp/QAT/warning.log) -eq 0 ]]
then
 echo -e "No WARNINGS found under /var/log/messages"
 rm -rf /tmp/QAT/warning.log
else
 echo -e "ERROR:- Still there are some WARNINGS logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog.log"
fi
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i failed > /tmp/QAT/failed.log
if [[ $(wc -l < /tmp/QAT/failed.log) -eq 0 ]]
then
 echo -e "No FAILED found under /var/log/messages"
 rm -rf /tmp/QAT/failed.log
else
 echo -e "ERROR:- Still there are some FAIL logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog.log"
fi
awk -v d1="$(date --date="-1440 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/messages | grep -i critical > /tmp/QAT/critical.log
if [[ $(wc -l < /tmp/QAT/critical.log) -eq 0 ]]
then
 echo -e "No ERRORS found under /var/log/messages"
 rm -rf /tmp/QAT/critical.log
else
 echo -e "ERROR:- Still there are some CRITICAL logs under /var/log/messages!!!! Please go and fix them ---- find the in file /tmp/QAT/varlog.log"
fi
if [[ -f /tmp/QAT/varlog.log ]]
then
 cp /dev/null /tmp/QAT/varlog.log
 echo -e "This was created on [$(date)]" >> /tmp/QAT/varlog.log
fi
if [[ -f /tmp/QAT/error.log ]]
then
 echo -e "++++++++++++++" >> /tmp/QAT/varlog.log
 echo -e "X ERROR LOGS X" >> /tmp/QAT/varlog.log
 echo -e "++++++++++++++" >> /tmp/QAT/varlog.log
 cat /tmp/QAT/error.log >> /tmp/QAT/varlog.log
 rm -rf /tmp/QAT/error.log
fi
if [[ -f /tmp/QAT/warning.log ]]
then 
 echo -e "++++++++++++++++" >> /tmp/QAT/varlog.log
 echo -e "X WARNING LOGS X" >> /tmp/QAT/varlog.log
 echo -e "++++++++++++++++" >> /tmp/QAT/varlog.log
 cat /tmp/QAT/warning.log >> /tmp/QAT/varlog.log
 rm -rf /tmp/QAT/warning.log
fi
if [[ -f /tmp/QAT/failed.log ]]
then 
 echo -e "+++++++++++++" >> /tmp/QAT/varlog.log
 echo -e "X FAIL LOGS X" >> /tmp/QAT/varlog.log
 echo -e "+++++++++++++" >> /tmp/QAT/varlog.log
 cat /tmp/QAT/failed.log >> /tmp/QAT/varlog.log
 rm -rf /tmp/QAT/failed.log
fi
if [[ -f /tmp/QAT/critical.log ]]
then
 echo -e "+++++++++++++++++" >> /tmp/QAT/varlog.log
 echo -e "X CRITICAL LOGS X" >> /tmp/QAT/varlog.log
 echo -e "+++++++++++++++++" >> /tmp/QAT/varlog.log
 cat /tmp/QAT/critical.log >> /tmp/QAT/varlog.log
 rm -rf /tmp/QAT/critical.log
fi
