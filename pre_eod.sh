#!/bin/bash
source ./init.sh

echo "*********** PRE-EOD: CREATE RESTORE POINT ***********"    >> "$LOG_FILE"
echo ""                                                         >> "$LOG_FILE"
echo "I- CREATE RESTORE POINT IN PRIMARY $PRIM_SVC"             >> "$LOG_FILE"
./create_rp.sh $USER $PASSWORD $PRIM_SVC $RP_NAME_PRIM          >> "$LOG_FILE"

echo ""                                                         >> "$LOG_FILE"
echo ""                                                         >> "$LOG_FILE"
echo "-----------------------------------------------------"    >> "$LOG_FILE"
echo ""                                                         >> "$LOG_FILE"
echo ""                                                         >> "$LOG_FILE"

echo "II- CREATE RESTORE POINT IN STANDBY $STB1_SVC"            >> "$LOG_FILE"
./create_rp.sh $USER $PASSWORD $STB1_SVC $RP_NAME_STB           >> "$LOG_FILE"

# echo ""
# echo "III- CREATE RESTORE POINT IN STANDBY $STB2_SVC"
# ./create_rp.sh $USER $PASSWORD $STB2_SVC $RP_NAME_STB

echo ""                                                         >> "$LOG_FILE"
echo "*********** COMPLETE CREATE RESTORE POINT ***********"    >> "$LOG_FILE"
echo ""                                                         >> "$LOG_FILE"