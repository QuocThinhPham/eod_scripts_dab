source ./db_utils.sh

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
