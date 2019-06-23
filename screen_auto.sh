#!/bin/bash

Program_name=$0

function usage() {
    echo "usage: $Program_name <user_name> <task_number> <type of the templete you wana use> <comma seperated hostnames>"
}

if [[ "$#" -lt "4" ]]
then
    usage
    exit 1
fi

user_name=$1
task_number=$2
template=$3
hosts=$4

function file_exists() {
    File=$1
    if [ -f $File ]
    then
        rm $File
    fi
}

function chk_cmd() {
    local return_=1
    type  $1 >/dev/null 2>&1 &&  { local return_=0; }
    echo "$return_"
    }

function screen_cmds() {
    case $1 in
        copy)
            screen -S  $scrn_name -X screen -t $case_strip
            screen -S  $scrn_name -p $case_strip -X stuff "icmd -cp -src a0570v0rapp0016:QATScript/qat_copy.sh -trgs localhost -u iuxu -cdir ~ -t $task_number -name copyqat $(echo -ne '\015')"
            sleep 3
            screen -S  $scrn_name -p $case_strip -X stuff "./qat_copy.sh -t $task_number $host $(echo -ne '\015')"
            sleep 5
            ;;
        ssh)
            screen -S  $scrn_name -p $case_strip -X stuff "ibmssh -i $task_number $user_name@$host $(echo -ne '\015')"
            sleep 3
            screen -S  $scrn_name -p $case_strip -X stuff "sudo su - $(echo -ne '\015')"
            ;;
        root)
            screen -S  $scrn_name -p $case_strip -X stuff "mv ~iuxu/QATScript . $(echo -ne '\015')"
            screen -S  $scrn_name -p $case_strip -X stuff "chown -R root:root QATScript $(echo -ne '\015')"
            ;;
        exec)
            cmd="cd QATScript; ./"${template}testing.sh""
            screen -S  $scrn_name -p $case_strip -X stuff "$cmd $(echo -ne '\015')"
            echo -e "Executing host $host in screen window $case_strip\n"
            sleep 5
            ;;
        log)
            screen -S  $scrn_name -p $case_strip  -X hardcopy  /tmp/QAT/${host}.log
            screen -S  $scrn_name -p $case_strip -X stuff "export host="${host}"\n"
            screen -S  $scrn_name -p $case_strip -X stuff "./result.sh $(echo -ne '\015')"


    esac
}

function run_cmd() {
    scrn_name=$1
    screen -S $scrn_name -A -d -m
    count=0
    IFS=","
    for host in $hosts
    do
        len_cases=${#case}
        #case_strip=${case:2:len_cases}
	    case_strip=${host}
        screen_cmds copy
        screen_cmds ssh
        screen_cmds root
        screen_cmds exec
        screen_cmds log
    done
}

function chk_sessions() {
    read -r -p "Please enter screen session name: " screen_name
    run_cmd $screen_name
}

# main_program
chk_sessions
