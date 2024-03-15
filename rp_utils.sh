source ./db_utils.sh
source ./init.sh

#getR1 "sys" "oracle123" "orclstb" "R1_EOD"
function getR1() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        select count(*) from v\$restore_point where name='$rp_name';
        exit;
EOF
)
quant=$(echo "$result" | awk '{$1=$1};1')
if [ "$quant" = "1" ]; then
    echo "existing"
else
    echo "none"
fi
}

#getR1_SCN "sys" "oracle123" "mydb" "R1_EOD"
function getR1_SCN() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog << EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        select to_char(scn) from v\$restore_point where name='$rp_name';
        exit;
EOF
)
current_scn=$(echo "$result" | awk '{$1=$1};1')
echo "$current_scn"
}

#getR1_today "sys" "oracle123" "mydb" "R1_EOD"
function getR1_today() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog << EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        SELECT count(*) FROM v\$restore_point WHERE TRUNC(time) = TRUNC(SYSDATE) and name='$rp_name';
        exit;
EOF
)
quant=$(echo "$result" | awk '{$1=$1};1')
if [ "$quant" = "1" ]; then
    echo "existing"
else
    echo "none"
fi
}

#createR1 "sys" "oracle123" "orclstb" "R1_EOD"
function createR1() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback on;
        create restore point "$rp_name" guarantee flashback database;
        exit;
EOF
)
echo "$result" | grep -q "Restore point created" > /dev/null
if [ $? -eq 0 ]; then
        echo "OK"
else
        echo "Failed"
fi
}

#dropR1 "sys" "oracle123" "orclstb" "R1_EOD"
function dropR1() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback on;
        drop restore point $rp_name;
        exit;
EOF
)
echo "$result" | grep -q "Restore point dropped" > /dev/null
if [ $? -eq 0 ]; then
        echo "OK"
else
        echo "Failed"
fi
}

#compareRP "sys" "oracle123" "mydb" "mydbstb" "R1_EOD_PRIM" "R1_EOD_STB"
function compareRP() {
    local user="$1"
    local password="$2"
    local service_prim="$3"
    local service_stb="$4"
    local rp_name_prim="$5"
    local rp_name_stb="$6"
    rp_prim_today=$(getR1_today "$user" "$password" "$service_prim" "$rp_name_prim")
    rp_stb_today=$(getR1_today "$user" "$password" "$service_stb" "$rp_name_stb")
    if [ "$rp_prim_today" = "existing" ] && [ "$rp_stb_today" = "existing" ]; then
        scn_prim=$(getR1_SCN "$user" "$password" "$service_prim" "$rp_name_prim")
        scn_stb=$(getR1_SCN "$user" "$password" "$service_stb" "$rp_name_stb")
        if [ "$scn_stb" -le "$scn_stb" ]; then
            echo "--> Restore point was created successfully"
            echo "--> You can continue the next step eod."
        else
            dropR1 "$user" "$password" "$service_prim" "$rp_name_prim"
            dropR1 "$user" "$password" "$service_stb" "$rp_name_stb"
            echo "--> Restore point was created fail"
        fi
    else
        echo "--> Restore point was created Fail"
    fi
}
