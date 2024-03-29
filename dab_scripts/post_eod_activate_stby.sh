# sh post_eod_revert_stby.sh
source ./constants.sh
source ./utils.sh
source ./dataguard.sh
source ./restore_point.sh
source ./database.sh

. /home/oracle/db10g_env fcclive

now=`date`
echo "~~~~~~~~~ $now ~~~~~~~~~"

#
echo "View log file: tail -500f $LOG_PATH"
echo "" > "$LOG_PATH"

f_db_activate_stby_to_primary $USER $PASS $DATABASES[2]
# f_db_revert_to_stby $USER $PASS $STBY_SERVICE