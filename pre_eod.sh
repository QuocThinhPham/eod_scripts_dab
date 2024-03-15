#!/bin/bash
source ./init.sh
source ./rp_utils.sh

echo "Pre-EOD: Create restore point is running..."
echo "This operation will take a few moments. The progress can be monitored in the following directory/file: $LOG_FILE"
echo "$(date "+%Y-%m-%d %H:%M:%S") *********** PRE-EOD: CREATE RESTORE POINT ***********"           >> "$LOG_FILE"
echo ""                                                                                             >> "$LOG_FILE"
echo "$(date "+%Y-%m-%d %H:%M:%S"): I- CREATE RESTORE POINT IN PRIMARY $PRIM_SVC"                   >> "$LOG_FILE"
echo ""                                                                                             >> "$LOG_FILE"
./create_rp.sh $USER $PASSWORD $PRIM_SVC $RP_NAME_PRIM                                              >> "$LOG_FILE"

echo ""                                                                                             >> "$LOG_FILE"
echo ""                                                                                             >> "$LOG_FILE"
echo "-----------------------------------------------------"                                        >> "$LOG_FILE"
echo ""                                                                                             >> "$LOG_FILE"
echo ""                                                                                             >> "$LOG_FILE"

echo "$(date "+%Y-%m-%d %H:%M:%S"): II- CREATE RESTORE POINT IN STANDBY $STB1_SVC"                  >> "$LOG_FILE"
./create_rp.sh $USER $PASSWORD $STB1_SVC $RP_NAME_STB                                               >> "$LOG_FILE"

# echo ""
# echo "III- CREATE RESTORE POINT IN STANDBY $STB2_SVC"
# ./create_rp.sh $USER $PASSWORD $STB2_SVC $RP_NAME_STB

echo "$(date "+%Y-%m-%d %H:%M:%S"): III- CHECK RESTORE POIN IN IN PRIMARY $PRIM_SVC AND STANDBY $STB1_SVC"        >> "$LOG_FILE"
compareRP  $USER $PASSWORD $PRIM_SVC $STB1_SVC $RP_NAME_PRIM $RP_NAME_STB                           >> "$LOG_FILE"


echo ""                                                                                             >> "$LOG_FILE"
echo "$(date "+%Y-%m-%d %H:%M:%S") *********** COMPLETE CREATE RESTORE POINT ***********"           >> "$LOG_FILE"
echo "echo "Pre-EOD: Done""