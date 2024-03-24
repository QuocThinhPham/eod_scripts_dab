# DESC: Get db Open Mode
# f_db_open_mode "$user" "$pass" "$service"
# return 'open_mode'
function f_db_open_mode() {
   open_mode=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select open_mode from v\$database;
   exit;
EOF
   )
   echo "$open_mode"
}

# DESC: Get db role
# f_db_database_role "$user" "$pass" "$service"
# return 'database_mode'
function f_db_database_role() {
   database_role=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select database_role from v\$database;
   exit;
EOF
   )
   echo "$database_role"
}

# DESC: Get db current scn
# f_db_get_current_scn "$user" "$pass" "$service"
# return 'current_scn'
function f_db_get_current_scn() {
   current_scn=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select to_char(current_scn) from v\$database;
   exit;
EOF
   )
   echo "$current_scn"
}

# DESC: Verify database_role and open_mode
# f_db_verify_database "$user" "$pass" "$service" "$check_what" "$value_to_check"
# return 'VERIFIED' | 'NOT_VERIFIED' | ''
function f_db_verify_database() {
   local user="$1"
   local pass="$2"
   local service="$3"
   local check_what=$(echo "$4" | awk '{print toupper($0)}')
   local value_to_check=$(echo "$5" | awk '{print toupper($0)}')

   # case statement
   # case "$check_what" in
   #    "DATABASE_ROLE")
   #       database_role=$(f_db_database_role $user $pass $service)
   #       if [ "$value_to_check" == "$database_role" ]; then
   #          echo "$VERIFIED"
   #       else
   #          echo "$NOT_VERIFIED"
   #       fi
   #       ;;
   #    "OPEN_MODE")
   #       open_mode=$(f_db_open_mode $user $pass $service)
   #       if [ "$value_to_check" == "$open_mode" ]; then
   #          echo "$VERIFIED"
   #       else
   #          echo "$NOT_VERIFIED"
   #       fi
   #       ;;
   #    *)
   #       echo ""
   #       ;;
   # esac

   if [ "$check_what" == "$DATABASE_ROLE" ]; then
      database_role=$(f_db_database_role $user $pass $service)
      if [ "$value_to_check" == "$database_role" ]; then
         echo "$VERIFIED"
      else
         echo "$NOT_VERIFIED"
      fi
   elif [ "$check_what" == "$OPEN_MODE" ]; then
      open_mode=$(f_db_open_mode $user $pass $service)
      if [ "$value_to_check" == "$open_mode" ]; then
         echo "$VERIFIED"
      else
         echo "$NOT_VERIFIED"
      fi
   else
      echo ""
      exit 0
   fi
}

# DESC: Start database with mode
# f_db_open_db $user $pass $service $mode
# return 'SUCCESS' | 'FAILED'
function f_db_open_db() {
   local user="$1"
   local pass="$2"
   local service="$3"
   local mode="$4"
   if [ ${#mode} -eq 0 ]; then
   message=$(sqlplus -S /nolog << EOF
   connect $1/$2@$3 as sysdba;
   startup;
EOF
   )
   else
   message=$(sqlplus -S /nolog << EOF
   connect $1/$2@$3 as sysdba;
   startup $mode;
EOF
   )
   fi
   echo "$message" | grep -qe "instance started" -e "Database mounted" -e "Database opened" > /dev/null
   if [ $? -eq 0 ]; then
   # $( ((${#mode} == 0)) && echo "" || echo " $mode" )
      f_u_show_log "$LOG_PATH" "Completed: Startup$( ((${#mode} == 0)) && echo "" || echo " $mode" )."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Startup$( ((${#mode} == 0)) && echo "" || echo " $mode" )."
      echo "$FAILED"
   fi
}

# DESC: Shutdown database with mode
# f_db_shutdown_db $user $pass $service $mode
# return 'SUCCESS' | 'FAILED'
function f_db_shutdown_db() {
   local user="$1"
   local pass="$2"
   local service="$3"
   local mode="$4"
   if [ ${#mode} -eq 0 ]; then
   message=$(sqlplus -S /nolog << EOF
   connect $1/$2@$3 as sysdba;
   shutdown immediate;
EOF
   )
   else
   message=$(sqlplus -S /nolog << EOF
   connect $1/$2@$3 as sysdba;
   shutdown $mode;
EOF
   )
   fi
   echo "$message" | grep -qe "instance shut down" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Shutdown $( ((${#mode} == 0)) && echo "immediate" || echo "$mode" )"
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Shutdown $( ((${#mode} == 0)) && echo "immediate" || echo "$mode" )"
      echo "$FAILED"
   fi
}


# DESC: Compare two SCN: Current SCN <> Restore Point SCN
# f_db_compare_scn $user $pass $service $restore_point_name
# return 'EQUAL' | 'NOT_EQUAL'
function f_db_compare_scn() {
   local user="$1"
   local pass="$2"
   local service="$3"
   local restore_point_name="$4"
   current_scn=$(f_db_get_current_scn $user $pass $service)
   restore_point_scn=$(f_rp_get_restore_point_scn $user $pass $service $restore_point_name)
   if [ "$current_scn" == "$restore_point_scn" ]; then
      f_u_show_log "$LOG_PATH" "Completed: Compare SCN: EQUAL."
      echo "$EQUAL"
   else
      f_u_show_log "$LOG_PATH" "Completed: Compare SCN: NOT EQUAL."
      echo "$NOT_EQUAL"
   fi
}

# f_db_activate
function f_db_activate() {
   local user="$1"
   local pass="$2"
   local service="$3"
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   alter database activate standby database;
   alter database open;
   exit;
EOF
   )
   echo "$message" | grep -q "Database altered" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Activate Physical Standby."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Activate Physical Standby."
      echo "$FAILED"
   fi
}

# f_db_convert_physical
function f_db_convert_physical() {
   local user="$1"
   local pass="$2"
   local service="$3"
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   alter database convert to physical standby;
   exit;
EOF
   )
   echo "$message" | grep -q "Database altered" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Convert to Physical Standby."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Convert to Physical Standby."
      echo "$FAILED"
   fi
}

# f_db_activate_stby_to_primary
function f_db_activate_stby_to_primary() {
   local user="$1"
   local pass="$2"
   local service="$3"
   msg_broker=$(f_dg_set_broker $user $pass $service "false")
   if [ "$msg_broker" == "$FAILED" ]; then
      echo "Try again."
      exit 0
   fi

   msg_stop_mrp=$(f_dg_stop_mrp $user $pass $service)

   mrp_is_active=$(f_dg_mrp_is_active $user $pass $service)
   if [ "$mrp_is_active" == "$ACTIVE" ]; then
      echo "Try again."
      exit 0
   fi

   db_role_verified=$(f_db_verify_database $user $pass $service "database_role" "physical standby")
   open_mode_verified=$(f_db_verify_database $user $pass $service "open_mode" "mounted")
   if [ "$db_role_verified" == "$NOT_VERIFIED" ] && [ "$open_mode_verified" == "$NOT_VERIFIED" ]; then
      echo "Try again."
      exit 0
   fi

   f_u_show_log "$LOG_PATH" "Database is Physical Standby and running in MOUNT mode."

   rp_is_existed=$(f_rp_restore_point_is_existed $user $pass $service "$POSTEOD_FCCREPORT")
   if [ "$rp_is_existed" == "$EXISTED" ]; then
      msg_rp_drop=$(f_rp_drop_restore_point $user $pass $service $POSTEOD_FCCREPORT)
   fi
   msg_rp_create=$(f_rp_create_restore_point $user $pass $service $POSTEOD_FCCREPORT)
   msg_check_rp_again="$NOT_EXISTED"
   while [ "$msg_check_rp_again" == "$NOT_EXISTED" ]
   do
      if [ "$msg_check_rp_again" == "$EXISTED" ]; then
         break
      fi
      msg_rp_create=$(f_rp_create_restore_point $user $pass $service $POSTEOD_FCCREPORT)
      msg_check_rp_again=$(f_rp_restore_point_is_existed $user $pass $service $POSTEOD_FCCREPORT)
   done

   f_u_show_log "$LOG_PATH" "Create restore point$POSTEOD_FCCREPORT\nCan ACTIVATE Physical Standby."

   msg_activate=$(f_db_activate $user $pass $service)
   if [ "$msg_activate" == "$FAILED" ]; then
      echo "Try again."
      exit 0
   else
      db_role_verified=$(f_db_verify_database $user $pass $service "database_role" "primary")
      open_mode_verified=$(f_db_verify_database $user $pass $service "open_mode" "read write")
      if [ "$db_role_verified" == "$VERIFIED" ] && [ "$open_mode_verified" == "$VERIFIED" ]; then
         f_u_show_log "$LOG_PATH" "Database is running on READ WRITE mode.\nCan run rebuild_index.sh"
         #sh rebuild_index.sh
      fi
   fi
}

# f_db_revert_to_stby
function f_db_revert_to_stby() {
   local user="$1"
   local pass="$2"
   local service="$3"
   msg_open_db=$(f_db_open_db $user $pass $service "mount force")
   if [ "$msg_open_db" == "$FAILED" ]; then
      echo "Try again."
      exit 0
   fi

   f_u_show_log "$LOG_PATH" "Database STARTUP MOUNT FORCE."

   db_role_verified=$(f_db_verify_database $user $pass $service "database_role" "primary")
   open_mode_verified=$(f_db_verify_database $user $pass $service "open_mode" "mounted")
   if [ "$db_role_verified" == "$NOT_VERIFIED" ] && [ "$open_mode_verified" == "$NOT_VERIFIED" ]; then
      echo "Try again."
      exit 0
   fi

   # Print message into log file
   f_u_show_log "$LOG_PATH" "Can REVERT to Physical Standby."
   rp_is_existed=$(f_rp_restore_point_is_existed $user $pass $service $POSTEOD_FCCREPORT)
   if [ "$rp_is_existed" == "$NOT_EXISTED" ]; then
      echo "Try again."
      exit 0
   else
      msg_flashback=$(f_rp_flashback_to_restore_point $user $pass $service $POSTEOD_FCCREPORT)
      if [ "$msg_flashback" == "$FAILED" ]; then
         echo "Try again."
         exit 0
      fi

      msg_convert=$(f_db_convert_physical $user $pass $service)
      if [ "$msg_convert" == "$FAILED" ]; then
         echo "Try again."
         exit 0
      fi

      msg_broker=$(f_dg_set_broker $user $pass $service "true")
      if [ "$msg_broker" == "$FAILED" ]; then
         echo "Try again."
         exit 0
      fi

      msg_open_db=$(f_db_open_db $user $pass $service "mount force")
      if [ "$msg_open_db" == "$FAILED" ]; then
         echo "Try again."
         exit 0
      fi

      f_u_show_log "$LOG_PATH" "Database STARTUP MOUNT FORCE."

      scn_compared=$(f_db_compare_scn $user $pass $service $POSTEOD_FCCREPORT)
      if [ "$scn_compared" == "$EQUAL" ]; then
         f_u_show_log "$LOG_PATH" "Convert to Physical Standby: SUCCESS\nBegin Sync From Primary ..."
      fi
   fi
}