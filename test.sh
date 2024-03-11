source ./utils.sh

. /home/oracle/db10g_env fcclive

###
result=$(compare_scn "sys" "oracle" "fcclive" "PREEOD_EOD_R1")
echo $result >> /home/oracle/shell_scripts/v1/pre_eod.log

###
result=$(get_current_scn "sys" "oracle" "fcclive")
echo $result >> /home/oracle/shell_scripts/v1/pre_eod.log