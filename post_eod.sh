#!/bin/bash

##########################
#### Post-EOD
# 1. stop apply redo and create restore point (R2)
# * - stop_apply.sh $user $pass $db
# * - return "Stopped" | "Failed"
# * -
# * - create_restore_point.sh $user $pass $db $rp_name
# * - return "Created" | "Failed"
#
# 2. check R2 is created?
### 2.1. created: continue
### 2.2. not created: failed
# * - get_restore_point $user $pass $db $rp_name
# * - return "OK" | "Failed"
#
# 3. activate stby to primary (check database_role, open_mode)
# * - activate_stby.sh $user $pass $db
# * - return "Activate $db: Successfully" | "Activate $db: Successfully"
#
# 4. run eod
# 5. check R2 is existed, then flashback to R2
# 6. check current scn = flashback scn
### 6.1. current scn == flashback scn: continue
### 6.2. current scn != flashback scn: failed
# * - compare_scn $user $pass $db $rp_name
# * - return "OK" | "Failed"
# 7. start transport and apply redo
##########################
