#!/bin/bash

function cancelApplyLog() {
    local user="$1"
    local password="$2"
    local service="$3"
    result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback on;
        alter database recover managed standby database cancel;
        exit;
EOF
)
echo "$result" 
}

#cancelApplyLog "sys" "oracle123" "orcl"

function getCurrentSequence() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        archive log list;
        exit;
EOF
)
sequence=$(echo "$result" | grep "Current log sequence" |awk '{print $NF}')
echo "$sequence"
}
#getCurrentSequence "sys" "oracle123" "mydb"

function waitSequenceEqualPrimStb(){
    local user="$1"
    local password="$2"
    local service="$3"
    sq_prim=$(getCurrentSequence "$1" "$2" "mydb")
    sq_stb=$(getCurrentSequence "$1" "$2" "$3")
    while [ "$sq_stb" -lt "$sq_prim" ]; do
    echo "--> Số hiện tại là: $sq_stb"
    echo "--> Waiting standby receive redolog...."
    sleep 3;
    done
}
#waitSequenceEqualPrimStb

function switchLogFile() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        alter system switch all logfile;
        exit;
EOF
)
echo "$result"
}
#switchLogFile "sys" "oracle123" "mydb"