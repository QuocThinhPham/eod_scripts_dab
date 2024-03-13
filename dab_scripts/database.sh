# f_db_open_mode
# f_db_database_role
# f_db_get_current_scn
# f_db_verify_database
# f_db_activate_stby_to_primary
# f_db_revert_to_stby
# f_db_compare_scn

# f_db_open_mode
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
# f_db_database_role
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
# f_db_get_current_scn
function f_db_get_current_scn() {
   current_scn=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select current_scn from v\$database;
   exit;
EOF
   )
   echo "$current_scn"
}
# f_db_verify_database $user $pass $service $check_what $value_to_check
function f_db_verify_database() {
   local user="$1"
   local pass="$2"
   local service="$3"
   local check_what=$(echo "$4" | awk '{print toupper($0)}')
   local value_to_check=$(echo "$5" | awk '{print toupper($0)}')
   if [ "$check_what" == 'DATABASE_ROLE' ]; then
      database_role=$(f_db_database_role $user $pass $service)
      if [ "$value_to_check" == "$database_role" ]; then
         echo "VERIFIED"
      else
         echo "NOT_VERIFIED"
      fi
   elif [ "$check_what" == 'OPEN_MODE' ]; then
      open_mode=$(f_db_open_mode $user $pass $service)
         if [ "$value_to_check" == "$open_mode" ]; then
         echo "VERIFIED"
      else
         echo "NOT_VERIFIED"
      fi
   else
      echo ""
      exit 0
   fi
}

# f_db_open_db
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
      echo "SUCCESS"
   else
      echo "FAILED"
   fi
}

# f_db_shutdown_db
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
   startup $mode;
EOF
   )
   fi
   echo "$message" | grep -qe "instance shut down" > /dev/null
   if [ $? -eq 0 ]; then
      echo "SUCCESS"
   else
      echo "FAILED"
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
      echo "SUCCESS"
   else
      echo "FAILED"
   fi
}

# f_db_activate_stby_to_primary
function f_db_activate_stby_to_primary() {
   local user="$1"
   local pass="$2"
   local service="$3"
   msg_broker=$(f_dg_set_broker $user $pass $service "false")
   if [ "$msg_broker" == "FAILED" ]; then
      echo "Try again."
      exit 0
   fi

   msg_stop_mrp=$(f_dg_stop_mrp $user $pass $service)

   mrp_is_active=$(f_dg_mrp_is_active $user $pass $service)
   if [ "$mrp_is_active" == "ACTIVE" ]; then
      echo "Try again."
      exit 0
   fi

   db_role_verified=$(f_db_verify_database $user $pass $service "database_role" "physical standby")
   open_mode_verified=$(f_db_verify_database $user $pass $service "open_mode" "mounted")
   if [ "$db_role_verified" == "NOT_VERIFIED" ] && [ "$open_mode_verified" == "NOT_VERIFIED" ]; then
      echo "Try again."
      exit 0
   fi

   rp_is_existed=$(f_rp_restore_point_is_existed $user $pass $service "POSTEOD_R2_FCCREPORT")
   if [ "$rp_is_existed" == "EXISTED" ]; then
      msg_rp_drop=$(f_rp_drop_restore_point $user $pass $service "POSTEOD_R2_FCCREPORT")
   else
      msg_rp_create=$(f_rp_create_restore_point $user $pass $service "POSTEOD_R2_FCCREPORT")
      msg_check_rp_again="NOT_EXISTED"
      while [ "$msg_check_rp_again" == "NOT_EXISTED" ]
      do
         if [ "$msg_check_rp_again" == "EXISTED" ]; then
            break
         fi
         msg_check_rp_again=$(f_rp_restore_point_is_existed $user $pass $service "POSTEOD_R2_FCCREPORT")
      done

      msg_activate=$(f_db_activate $user $pass $service)
      if [ "$msg_activate" == "FAILED" ]; then
         echo "Try again."
         exit 0
      else
         db_role_verified=$(f_db_verify_database $user $pass $service "database_role" "primary")
         open_mode_verified=$(f_db_verify_database $user $pass $service "open_mode" "read write")
         if [ "$db_role_verified" == "VERIFIED" ] && [ "$open_mode_verified" == "VERIFIED" ]; then
            printf "Activate Standby Database Successfully."
         fi
      fi
   fi
}

# f_db_revert_to_stby

# f_db_compare_scn
function f_db_compare_scn() {
   local user="$1"
   local pass="$2"
   local service="$3"
   local restore_point_name="$4"
   current_scn=$(f_db_get_current_scn $user $pass $service)
   restore_point_scn=$(f_rp_get_restore_point_scn $user $pass $service $restore_point_name)
   if [ "$current_scn" == "$restore_point_scn" ]; then
      echo "EQUAL"
   else
      echo "NOT_EQUAL"
   fi
}