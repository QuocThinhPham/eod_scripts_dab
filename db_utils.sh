#!/bin/bash
. /home/oracle/db11_env orclstb

function getDbStart() {
        local user="$1"
        local password="$2"
        local service="$3"
# check datbase startup or shutdown. Return 0 (false) database down, return 1 (true) databse up
        echo "exit" | sqlplus -S $user/$password@$service as sysdba | grep -q "idle instance" > /dev/null
        if [ $? -eq 0 ]; then
                echo "Down"
        else
                echo "Up"
        fi
}
#db_status=$(isDbStart)
## Kiểm tra biến db_status và thực hiện hành động tương ứng
#if [ "$db_status" -eq 0 ]; then
#    echo "Db down"
#else
#    echo "Db up"
#fi

function getDbRole() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        SELECT database_role FROM v\$database;
        exit;
EOF
)
echo "$result"
}
#getDbRole "sys" "oracle123" "orclstb"

function getDbMode() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        SELECT open_mode FROM v\$database;
        exit;
EOF
)
echo "$result"
}
#getDbMode "sys" "oracle123" "orclstb"

function getDbName() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        SELECT name FROM v\$database;
        exit;
EOF
)
echo "$result"
}

function getFlashBackOn() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        SELECT flashback_on FROM v\$database;
        exit;
EOF
)
echo "$result"
}

function getDbSCN() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        SELECT current_scn FROM v\$database;
        exit;
EOF
)
current_scn=$(echo "$result" | awk '{$1=$1};1')
echo "$current_scn"
}
#getDbSCN "sys" "oracle123" "orclstb"
