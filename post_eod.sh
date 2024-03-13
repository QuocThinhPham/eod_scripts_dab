#!/bin/bash

##########################
#### Post-EOD
# 1. stop apply redo and create restore point (R2)
# * - stop_apply.sh $user $pass $db
# * - return "Stopped" | "Failed"
# * -
# stop mrp process
f_stop_mrp $user $pass $service
# check mrp process
# ==> active: continue
# or
# ==> inactive: stop mrp process
f_mrp_is_active $sys $pass $service
# * - create_restore_point.sh $user $pass $db $rp_name
# * - return "Created" | "Failed"
# create restore point
f_create_restore_point $user $pass $service $rp_name
# check restore point
# ==> created: continue
# or
# ==> not created:

# 3. activate stby to primary (check database_role, open_mode)
# * - activate_stby.sh $user $pass $db
# * - return "Activate $db: Successfully" | "Activate $db: Successfully"
# check open_mode | database_role
# ==> physical standby: activate
# or
# ==> primary: revert
f_verify_database $user $pass $service
# activate stby to primary
f_activate_stby_to_primary $user $pass $service
# 4. run eod

# check restore point
# ==> existed: continue
# or
# ==> not existed: exit 0
f_restore_point_is_existed $user $pass $service $rp_name

# flashback to restore point
f_flashback_to_restore_point $user $pass $service $rp_name

# check current_scn and scn of res_point
# ==> equal: continue
# or
# ==> not equal: exit 0
f_compare_scn $user $pass $service $rp_name

# revert to stby
f_revert_to_stby $user $pass $service

# 7. start transport and apply redo and check lag
# * - start_apply.sh $user $pass $db
# *** - check_lag.sh
# *** - return "Sync" | "Not Sync"
# * - return "Stopped" | "Failed"
# * -
f_start_mrp $user $pass $service
# check mrp process
# ==> active: continue
# or
# ==> inactive: stop mrp process
f_mrp_is_active $sys $pass $service

f_check_apply_lag $user $pass $service
##########################
