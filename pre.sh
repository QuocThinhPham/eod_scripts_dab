#!/bin/bash
source ./init.sh
source ./rp_utils.sh

echo ""
echo "$(date "+%Y-%m-%d %H:%M:%S")"
echo "*********** PRE-EOD: CREATE RESTORE POINT ***********"
echo ""
echo "$(date "+%Y-%m-%d %H:%M:%S")"
echo "I- CREATE RESTORE POINT IN PRIMARY $PRIM_SVC"
./create_rp.sh $USER $PASSWORD $PRIM_SVC $RP_NAME_PRIM

echo ""
echo "-----------------------------------------------------"
echo "$(date "+%Y-%m-%d %H:%M:%S")"
echo "II- CREATE RESTORE POINT IN STANDBY $STB1_SVC"
./create_rp.sh $USER $PASSWORD $STB1_SVC $RP_NAME_STB

echo ""
echo "-----------------------------------------------------"
echo "$(date "+%Y-%m-%d %H:%M:%S")"
echo "III- CREATE RESTORE POINT IN STANDBY $STB2_SVC"
./create_rp.sh $USER $PASSWORD $STB2_SVC $RP_NAME_STB

echo ""
echo "-----------------------------------------------------"
echo "$(date "+%Y-%m-%d %H:%M:%S"):"
echo "IV- CHECK RESTORE POIN IN IN PRIMARY $PRIM_SVC AND STANDBY $STB1_SVC"
compareRP  $USER $PASSWORD $PRIM_SVC $STB1_SVC $STB2_SVC $RP_NAME_PRIM $RP_NAME_STB $RP_NAME_STB