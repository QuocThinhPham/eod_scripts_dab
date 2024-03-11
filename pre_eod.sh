#!/bin/bash
source ./db_utils.sh
source ./get_R1.sh
source ./drop_R1.sh
source ./create_R1.sh
source ./flashback.sh

#---- Login primary
echo -n "Username: ";
read user

# password
echo -n "Password: ";
read password

# service
echo -n "Service: ";
read service

#---- Parameter init
stb1="orcl"
prim_scn=-1
stb1_scn=-1
stb2_scn=-1

echo "B1"
### 1. Check R1 existing
rp_r1=$(getR1 "$user" "$password" "$service" "R1_EOD")
db_role=$(getDbRole "$user" "$password" "$service")
db_mode=$(getDbMode "$user" "$password" "$service")
db_name=$(getDbName "$user" "$password" "$service")

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
    drop_r1=$(dropR1 "$user" "$password" "$service" "R1_EOD")
    echo "$drop_r1"
    rp_r1="none"
fi

echo "B4"
### 4. Create R1
if [ "$db_role" = "PRIMARY" ] && [ "$rp_r1" = "none" ]; then
    create_r1=$(createR1 "$user" "$password" "$service" "R1_EOD")
    echo "$create_r1"

    ### Thuc hien tao tren stb
    scn_r1=$(getR1_SCN "$user" "$password" "$service" "R1_EOD")
    echo "scn_r1"
    flashback_r1=$(flashbackToSCN "$user" "$password" "$stb1" "$scn_r1")
    echo "$create_r1"
    create_r1=$(createR1 "$user" "$password" "$stb1" "R1_EOD_STB")
    echo "$create_r1"
fi
