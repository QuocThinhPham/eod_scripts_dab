# sh test_script.sh
source ./constants.sh
source ./utils.sh
source ./dataguard.sh
source ./restore_point.sh
source ./database.sh

. /home/oracle/db10g_env fcclive

now=`date`
echo "~~~~~~~~~ $now ~~~~~~~~~"

echo -n "Enter your password: "
read -s pass
echo
echo "=================== BEGIN ======================="
echo "----- I. restore_point.sh"

# restore_point.sh - f_rp_get_restore_point_name
restore_point_name=$(f_rp_get_restore_point_name "sys" $pass "fccreport" "POSTEOD_R2_FCCREPORT")
echo "1. restore_point.sh - f_rp_get_restore_point_name: $restore_point_name"
# restore_point.sh - f_rp_get_restore_point_scn
restore_point_scn=$(f_rp_get_restore_point_scn "sys" $pass "fccreport" "POSTEOD_R2_FCCREPORT")
echo "2. restore_point.sh - f_rp_get_restore_point_scn: $restore_point_scn"
# restore_point.sh - f_rp_create_restore_point
rp_create_message=$(f_rp_create_restore_point "sys" $pass "fccreport" "POSTEOD_R2_TEST")
echo "3. restore_point.sh - f_rp_create_restore_point: $rp_create_message"
# restore_point.sh - f_rp_restore_point_is_existed
is_existed=$(f_rp_restore_point_is_existed "sys" $pass "fccreport" "POSTEOD_R2_TEST")
echo "4. restore_point.sh - f_rp_restore_point_is_existed: $is_existed"
# restore_point.sh - f_rp_drop_restore_point
rp_drop_message=$(f_rp_drop_restore_point "sys" $pass "fccreport" "POSTEOD_R2_TEST")
echo "3. restore_point.sh - f_rp_create_restore_point: $rp_drop_message"
# restore_point.sh - f_rp_restore_point_is_existed
not_existed=$(f_rp_restore_point_is_existed "sys" $pass "fccreport" "POSTEOD_R2_TEST1")
echo "6. restore_point.sh - f_rp_restore_point_is_existed: $not_existed"

echo "-----"
echo "----- II. database.sh"

# database.sh - f_db_open_mode
open_mode=$(f_db_open_mode "sys" $pass "fccreport")
echo "1. database.sh - f_db_open_mode: $open_mode"
# database.sh - f_db_database_role
database_role=$(f_db_database_role "sys" $pass "fccreport")
echo "2. database.sh - f_db_database_role: $database_role"
# database.sh - f_db_get_current_scn
current_scn=$(f_db_get_current_scn "sys" $pass "fccreport")
echo "3. database.sh - f_db_get_current_scn: $current_scn"
# database.sh - f_db_verify_database
db_role_verified=$(f_db_verify_database "sys" $pass "fccreport" "database_role" "primary")
echo "4.1. database.sh - f_db_verify_database: $db_role_verified"
# database.sh - f_db_verify_database
db_role_verified=$(f_db_verify_database "sys" $pass "fccreport" "database_role" "physical standby")
echo "4.2. database.sh - f_db_verify_database: $db_role_verified"
# database.sh - f_db_verify_database
open_mode_verified=$(f_db_verify_database "sys" $pass "fccreport" "open_mode" "mounted")
echo "4.4. database.sh - f_db_verify_database: $open_mode_verified"
# database.sh - f_db_verify_database
open_mode_verified=$(f_db_verify_database "sys" $pass "fccreport" "open_mode" "open")
echo "4.4. database.sh - f_db_verify_database: $open_mode_verified"
# database.sh - f_db_compare_scn
scn_compared=$(f_db_compare_scn "sys" $pass "fccreport" "RP_TO_COMPARE")
echo "5. database.sh - f_db_compare_scn: $scn_compared"

echo "-----"
echo "----- III. dataguard.sh"

# dataguard.sh - f_dg_stop_mrp
message=$(f_dg_stop_mrp "sys" $pass "fccreport")
echo "1. database.sh - f_dg_stop_mrp:"
echo "$message"
# dataguard.sh - f_dg_mrp_is_active
mrp_is_active=$(f_dg_mrp_is_active "sys" $pass "fccreport")
echo "3.1. database.sh - f_dg_mrp_is_active:"
echo "$mrp_is_active"
# dataguard.sh - f_dg_start_mrp
message=$(f_dg_start_mrp "sys" $pass "fccreport")
echo "2. database.sh - f_dg_start_mrp:"
echo "$message"
# dataguard.sh - f_dg_mrp_is_active
mrp_is_active=$(f_dg_mrp_is_active "sys" $pass "fccreport")
echo "3.2. database.sh - f_dg_mrp_is_active:"
echo "$mrp_is_active"
# dataguard.sh - f_dg_check_apply_lag
echo "3.2. database.sh - f_dg_check_apply_lag:"
f_dg_check_apply_lag "sys" $pass "fccreport"

echo "-----"
echo ""
echo "==================== END ========================"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"



f_db_activate_stby_to_primary "sys" $pass "fccreport"