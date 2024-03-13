# f_dg_stop_mrp
# f_dg_start_mrp
# f_dg_mrp_is_active
# f_dg_check_apply_lag

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
      echo "Set dg_broker_start: $value"
   else
      echo "FAILED"
   fi
}

# f_dg_stop_mrp
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
      echo "SUCCESS"
   else
      echo "FAILED"
   fi
}
# f_dg_start_mrp
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
      echo "SUCCESS"
   else
      echo "FAILED"
   fi
}
# f_dg_mrp_is_active
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
      echo "NOT_ACTIVE"
      # echo "The Managed Recovery process is not active."
      return 0
   else
      echo "ACTIVE"
      # echo "The Managed Recovery process is active."
   fi
}

# f_dg_check_apply_lag
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
