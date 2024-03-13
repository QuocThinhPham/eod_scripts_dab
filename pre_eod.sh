#!/bin/bash
source ./init.sh

echo "*********** PRE-EOD: CREATE RESTORE POINT ***********"
echo ""
echo "I- CREATE RESTORE POINT IN PRIMARY $PRIM_SVC"
./create_rp.sh $USER $PASSWORD $PRIM_SVC $RP_NAME_PRIM

echo ""
echo "II- CREATE RESTORE POINT IN STANDBY $STB1_SVC"
./create_rp.sh $USER $PASSWORD $STB1_SVC $RP_NAME_STB

# echo ""
# echo "III- CREATE RESTORE POINT IN STANDBY $STB2_SVC"
# ./create_rp.sh $USER $PASSWORD $STB2_SVC $RP_NAME_STB

echo ""
echo "*********** COMPLETE CREATE RESTORE POINT ***********"
