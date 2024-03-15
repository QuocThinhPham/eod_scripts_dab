#!/bin/bash
source ./init.sh
source ./db_utils.sh
source ./rp_utils.sh
source ./flashback_utils.sh
source ./dg_utils.sh

user="$1"
password="$2"
service="$3"
rp_name="$4"

### 1. Check login to database
echo ""
echo "1. Check login to database"
login_prim=$(login_validate "$user" "$password" "$service")
if [ "$login_prim" = "Login failed" ]; then
    echo "--> Login failed. Please check your username, password and service name"
    exit 1
fi
echo "--> Login to $service successfully."

### 2. Check R1 existing
echo ""
echo "2. Check existing restore point"
db_role=$(getDbRole "$user" "$password" "$service")
db_mode=$(getDbMode "$user" "$password" "$service")
db_name=$(getDbName "$user" "$password" "$service")
rp_r1=$(getR1 "$user" "$password" "$service" "$rp_name")
if [ "$rp_r1" = "existing" ]; then
    echo "--> Restore point $rp_name existing."
else
    echo "--> Have no Restore point $rp_name "
fi

### Drop R1
echo ""
if [ "$rp_r1" = "existing" ]; then
    echo "*** Drop old existing $rp_name restore point"
    drop_r1=$(dropR1 "$user" "$password" "$service" "$rp_name")
    echo "$drop_r1"
    rp_r1=$(getR1 "$user" "$password" "$service" "$rp_name")
    if [ "$rp_r1" = "none" ]; then
        echo "--> Drop $rp_name restore point successfully"
    fi
fi

### 3. Create R1
echo ""
echo "3. Create restore point $rp_name"
if [ "$db_role" = "PRIMARY" ] && [ "$rp_r1" = "none" ]; then
    echo "--- On Primary"
    ### Cancel apply log in standby
    echo "Cancel apply log in standby"
    apply_off=$(cancelApplyLog "$user" "$password" "$STB1_SVC")
    echo "$apply_off"

    ### Create restorepoint
    create_r1=$(createR1 "$user" "$password" "$service" "$rp_name")
    rp_r1=$(getR1 "$user" "$password" "$service" "$rp_name")
    if [ "$rp_r1" = "existing" ]; then
        echo "--> Create $rp_name in primary successfully."
    else
        echo "--> Create $rp_name in primary failed."
    fi
    switchLogFile "$user" "$password" "$service"
fi

if [ "$db_role" = "PHYSICAL STANDBY" ] && [ "$rp_r1" = "none" ]; then
    echo "--- On Standby"
    ### Thuc hien tao rp tren stb
    scn_r1=$(getR1_SCN "$user" "$password" "$PRIM_SVC" "$RP_NAME_PRIM")
    echo "$scn_r1"
    echo "--> Waiting standby recieve redo log $scn_r1"
    waitSequenceEqualPrimStb "$user" "$password" "$service"

    echo "--> Recover database until scn $scn_r1"
    recover=$(recoverToScn "$user" "$password" "$service" "$scn_r1")

    create_r1=$(createR1 "$user" "$password" "$service" "$rp_name")
    echo "--> Create restore point: $create_r1"

    echo "Turn on apply log in standby"
    apply_on=$(applyLog "$user" "$password" "$service")
    echo "$apply_on"
    
fi

# thong bao tao thanh cong hay that bai
rp_r1=$(getR1 "$user" "$password" "$service" "$rp_name")
if [ "$rp_r1" = "existing" ]; then
    echo "Done create restore point in $db_role"
else
    echo "Fail create restore point in $db_role"
fi
