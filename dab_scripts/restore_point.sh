# f_rp_get_restore_point_name
# f_rp_get_restore_point_scn
# f_rp_create_restore_point
# f_rp_drop_restore_point
# f_rp_restore_point_is_existed

   # local user="$1"
   # local password="$2"
   # local service="$3"
   # local restore_point_name="$4"

# f_rp_get_restore_point_name
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

# f_rp_get_restore_point_scn
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
# f_rp_create_restore_point
function f_rp_create_restore_point() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   create restore point $4 guarantee flashback database;
   exit;
EOF
   )
   echo "$message"
}
# f_rp_drop_restore_point
function f_rp_drop_restore_point() {
   message=$(sqlplus -S /nolog <<EOF
   connect $1/$2@$3 as sysdba;
   set pages 0;
   set heading off feedback on verify off;
   drop restore point $4;
   exit;
EOF
   )
   echo "$message"
}
# f_rp_restore_point_is_existed
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
      echo "NOT_EXISTED"
   else
      echo "EXISTED"
   fi
}