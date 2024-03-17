# DESC: Set dg_broker_start
# f_dg_set_broker "$user" "$pass" "$service" "$value"
# return 'SUCCESS' | 'FAILED'
function f_dg_set_broker() {
   value=$(echo "$4" | awk '{print toupper($0)}')
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   alter system set dg_broker_start=$value scope=both sid='*';
   exit;
EOF
   )
   echo "$message" | grep -q "System altered" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Set dg_broker_start='$value'."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Set dg_broker_start='$value'."
      echo "$FAILED"
   fi
}

# DESC: Cancel The Managed Recovery
# f_dg_stop_mrp "$user" "$pass" "$service"
# return 'SUCCESS' | 'FAILED'
function f_dg_stop_mrp() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   alter database recover managed standby database cancel;
   exit;
EOF
   )
   echo "$message" | grep -q "Database altered" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Stop The Managed Recovery."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Stop The Managed Recovery."
      echo "$FAILED"
   fi
}


# DESC: Start The Managed Recovery
# f_dg_start_mrp "$user" "$pass" "$service"
# return 'SUCCESS' | 'FAILED'
function f_dg_start_mrp() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   alter database recover managed standby database using current logfile disconnect from session;
   exit;
EOF
   )
   echo "$message" | grep -q "Database altered" > /dev/null
   if [ $? -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "Completed: Start The Managed Recovery."
      echo "$SUCCESS"
   else
      f_u_show_log "$LOG_PATH" "Failed: Start The Managed Recovery."
      echo "$FAILED"
   fi
}

# DESC: Check The Managed Recovery Process
# f_dg_mrp_is_active "$user" "$pass" "$service"
# return 'ACTIVE' | 'NOT_ACTIVE'
function f_dg_mrp_is_active() {
   number_of_mrp=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select count(*) from v\$managed_standby where upper(process) like '%MRP%';
   exit;
EOF
   )
   if [ "$number_of_mrp" -eq 0 ]; then
      f_u_show_log "$LOG_PATH" "The Managed Recovery process is not active."
      echo "$NOT_ACTIVE"
   else
      f_u_show_log "$LOG_PATH" "The Managed Recovery process is active."
      echo "$ACTIVE"
   fi
}

# DESC: Check The Managed Recovery Process
# f_dg_check_apply_lag "$user" "$pass" "$service"
# return
function f_dg_check_apply_lag() {
   transport_lag=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select value from v\$dataguard_stats where lower(name)='transport lag';
   exit;
EOF
   )
   apply_lag=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback off verify off;
   select value from v\$dataguard_stats where lower(name)='apply lag';
   exit;
EOF
   )
   printf " - Transport Lag:\t%s\n - Apply Lag:\t\t%s\n" "$transport_lag" "$apply_lag"
}
