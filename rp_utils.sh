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
echo "$result"
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

function getR1_name_scn() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog << EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        set lines 200;
        col name for a50;
        col scn for a50;
        select name, to_char(scn) from v\$restore_point where name='$rp_name';
        exit;
EOF
)
echo "$result"
}

#compareRP "sys" "oracle123" "mydb" "mydbstb1" "mydbstb2" "R1_EOD_PRIM" "R1_EOD_STB" "R1_EOD_STB"
function compareRP() {
    local user="$1"
    local password="$2"
    local service_prim="$3"
    local service_stb1="$4"
    local service_stb2="$5"
    local rp_name_prim="$6"
    local rp_name_stb1="$7"
    local rp_name_stb2="$8"
    rp_prim_today=$(getR1_today "$user" "$password" "$service_prim" "$rp_name_prim")
    rp_stb1_today=$(getR1_today "$user" "$password" "$service_stb1" "$rp_name_stb1")
    rp_stb2_today=$(getR1_today "$user" "$password" "$service_stb2" "$rp_name_stb2")
    if [ "$rp_prim_today" = "existing" ] && [ "$rp_stb1_today" = "existing" ] && [ "$rp_stb2_today" = "existing" ]; then
        # Get scn rp
        scn_prim=$(getR1_SCN "$user" "$password" "$service_prim" "$rp_name_prim")
        scn_stb1=$(getR1_SCN "$user" "$password" "$service_stb1" "$rp_name_stb1")
        scn_stb2=$(getR1_SCN "$user" "$password" "$service_stb2" "$rp_name_stb2")
        # Print name, scn rp
        echo "--> Information about created restore point."
        getR1_name_scn "$user" "$password" "$service_prim" "$rp_name_prim"
        getR1_name_scn "$user" "$password" "$service_stb1" "$rp_name_stb1"
        getR1_name_scn "$user" "$password" "$service_stb1" "$rp_name_stb2"
        echo ""
        # Compare scn
        if [ "$scn_stb1" -le "$scn_prim" ] && [ "$scn_stb2" -le "$scn_prim" ]; then
            echo "--> Restore point was created SUCCESSFULLY."
            echo "--> You CAN continue the next step EOD."
        else
            dropR1 "$user" "$password" "$service_prim" "$rp_name_prim"
            dropR1 "$user" "$password" "$service_stb1" "$rp_name_stb1"
            dropR1 "$user" "$password" "$service_stb2" "$rp_name_stb2"
            echo "--> Standby's SCN restore point is LARGER THAN SCN Primary's SCN restore point."
            echo "--> Restore point was created FAIL."
            echo "--> You CAN'T the next step EOD. Please contract with DBA team."
        fi
    else
        echo "--> Restore point was created FAIL."
        echo "--> You CAN'T the next step EOD. Please contract with DBA team."
    fi
}
