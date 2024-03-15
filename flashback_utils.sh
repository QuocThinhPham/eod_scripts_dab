source ./db_utils.sh

function flashbackToRP() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    cancelApplyLog $user $password $service
    fb_on=$(getFlashBackOn "$user" "$password" "$service")
    shudown=$(sqlplus -S /nolog <<EOF
    connect $user/$password@$service as sysdba;
    set heading off;
    set pagesize 0;
    set feedback on;
    shutdown immediate;
    startup mount;
    flashback database to restore point $rp_name; 
    exit;
EOF
)
echo "$result" | grep -q "Flashback complete" > /dev/null
if [ $? -eq 0 ]; then
        echo "OK"
else
        echo "Failed"
fi
}

#flashbackToSCN "sys" "oracle123" "orcl" "9143497"
function flashbackToSCN() {
    local user="$1"
    local password="$2"
    local service="$3"
    local scn="$4"
    shutdown=$(sqlplus -S /nolog <<EOF
    connect $user/$password@$service as sysdba;
    set heading off;
    set pagesize 0;
    set feedback on;
    shutdown immediate;
    startup mount;
    flashback database to scn $scn; 
    exit;
EOF
)
echo "$result"
}

#recoverToScn "sys" "oracle123" "mydbstb" "2326345"
function recoverToScn() {
    local user="$1"
    local password="$2"
    local service="$3"
    local scn="$4"
    scn_until=$(($scn-1))
    new_scn=$(echo "$scn_until")
    echo "recover database until scn $new_scn"
    result=$(rman target $user/$password@$service << EOF
    recover database until scn $new_scn;
    exit;
EOF
)
echo "$result"
}