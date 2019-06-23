#!/bin/bash
cat /tmp/QAT/$host.log | grep -i error | awk '{$1=""; print}' > /tmp/QAT/$host_defects
if [[ $(wc -l < /tmp/QAT/$host_defects) -eq 0 ]]
then
 echo -e "Great Stuff :) !!! not defects found on the host ${host}"
else
 echo -e "$(wc -l < /tmp/QAT/$host_defects) defects are found while testing the host ${host} and they are......"
 cat -n /tmp/QAT/$host_defects
fi
