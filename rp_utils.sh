source ./db_utils.sh
source ./init.sh

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
#getR1 "sys" "oracle123" "orclstb" "R1_EOD"

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
#getR1_SCN "sys" "oracle123" "mydb" "R1_EOD"

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

#createR1 "sys" "oracle123" "orclstb" "R1_EOD"

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

#dropR1 "sys" "oracle123" "orclstb" "R1_EOD"
