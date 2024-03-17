# DESC: Get Restore Point Name
# f_rp_get_restore_point_name "$user" "$pass" "$service" "$restore_point_name"
# return 'restore_point_name'
function f_rp_get_restore_point_name() {
   rp_name=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select name from v\$restore_point where name like '%$4%';
   exit;
EOF
   )
   echo "$rp_name"
}

# DESC: Get Restore Point SCN
# f_rp_get_restore_point_scn "$user" "$pass" "$service" "$restore_point_name"
# return 'restore_point_scn'
function f_rp_get_restore_point_scn() {
   rp_scn=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select to_char(scn) from v\$restore_point where name like '%$4%';
   exit;
EOF
   )
   echo "$rp_scn"
}

# DESC: Create Restore Point
# f_rp_create_restore_point "$user" "$pass" "$service" "$restore_point_name"
# return 'SUCCESS' | 'FAILED'
function f_rp_create_restore_point() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   create restore point $4 guarantee flashback database;
   exit;
EOF
   )
   echo "$message" | grep -q "Restore point created" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Create Restore Point $4."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Completed: Create Restore Point $4."
      echo "$FAILED"
   fi
}

# DESC: Drop Restore Point
# f_rp_drop_restore_point "$user" "$pass" "$service" "$restore_point_name"
# return 'SUCCESS' | 'FAILED'
function f_rp_drop_restore_point() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   drop restore point $4;
   exit;
EOF
   )
   echo "$message" | grep -q "Restore point dropped" > /dev/null
   if [ $? -eq 0 ]; then
      echo "$(date)" >> "$LOG_PATH"
      echo "Completed: Drop restore point $4." >> "$LOG_PATH"
      echo "$SUCCESS"
   else
      echo "$(date)" >> "$LOG_PATH"
      echo "Failed: Drop restore point $4." >> "$LOG_PATH"
      echo "$FAILED"
   fi
}

# DESC: Check Restore Point
# f_rp_restore_point_is_existed "$user" "$pass" "$service" "$restore_point_name"
# return 'EXISTED' | 'NOT_EXISTED'
function f_rp_restore_point_is_existed() {
   is_existed=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select count(*) from v\$restore_point where name='$4';
   exit;
EOF
   )
   if [ "$is_existed" -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Check Restore Point $4: Not Existed."
      echo "$NOT_EXISTED"
   else
      f_u_show_log "$LOG_PATH" "Check Restore Point $4: Existed."
      echo "$EXISTED"
   fi
}

# DESC: Flashback to Restore Point
# f_rp_flashback_to_restore_point "$user" "$pass" "$service" "$restore_point_name"
# return 'SUCCESS' | 'FAILED'
function f_rp_flashback_to_restore_point() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   flashback database to restore point $4;
   exit;
EOF
   )
   echo "$message" | grep -q "Flashback complete" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Flashback to Restore Point $4."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Flashback to Restore Point $4."
      echo "$FAILED"
   fi
}