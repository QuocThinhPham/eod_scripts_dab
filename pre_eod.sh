#!/bin/bash
source ./db_utils.sh
source ./get_R1.sh
source ./drop_R1.sh
source ./create_R1.sh
source ./flashback.sh

echo "B0: login to primary"
#---- Login primary
echo -n "Username: ";
read user
echo -n "Password: ";
read password
echo -n "Service: ";
read service_prim

login_prim=$(login_validate "$user" "$password" "$service_prim")
if [ "$login_prim" = "Login failed" ]; then
    echo "Login failed. Please check your username, password and service name"
    exit 1
fi
echo "Login successfully."

#---- Parameter init
service_stb1="orcl"

echo "B1: Check existing restore point in primary"
### 1. Check R1 existing
db_role=$(getDbRole "$user" "$password" "$service_prim")
db_mode=$(getDbMode "$user" "$password" "$service_prim")
db_name=$(getDbName "$user" "$password" "$service_prim")
rp_r1=$(getR1 "$user" "$password" "$service_prim" "R1_EOD")
if [ "$rp_r1" = "existing" ]; then
    echo "Restore point R1_EOD"
fi

echo "B2"
### 2. Revert physical to standby
if [ "$db_name" = "FCCREPORT" ] && [ "$db_mode" = "READ WRITE" ] && ["$rp_r1" = "existing" ]; then
    echo "Do you want to revert standby database - read write mode to physical standby?"
    echo "Standby can phai revert"
fi

echo "B3"
### 3. Drop R1
echo "$rp_r1"
if [ "$rp_r1" = "existing" ]; then
    echo "Do you want to drop R1_EOD?"
    drop_r1=$(dropR1 "$user" "$password" "$service_prim" "R1_EOD")
    echo "$drop_r1"
    rp_r1="none"
fi

echo "B4"
### 4. Create R1
if [ "$db_role" = "PRIMARY" ] && [ "$rp_r1" = "none" ]; then
    create_r1=$(createR1 "$user" "$password" "$service_prim" "R1_EOD")
    echo "$create_r1"

    ### Thuc hien tao tren stb
    scn_r1=$(getR1_SCN "$user" "$password" "$service_prim" "R1_EOD")
    echo "scn_r1"
    flashback_r1=$(flashbackToSCN "$user" "$password" "$service_stb1" "$scn_r1")
    echo "$create_r1"
    create_r1=$(createR1 "$user" "$password" "$service_stb1" "R1_EOD_STB")
    echo "$create_r1"
fi
