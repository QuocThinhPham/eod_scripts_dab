########################
# get_restore_point_name "sys" "oracle" "fcclive" "PREEOD_R1_FCCLIVE"
# Check time
########################
function get_restore_point_name() {
   local user="$1"
   local pass="$2"
   local databse="$3"
	local alias="$4"
	local restore_point_name=""
	restore_point_name=$(sqlplus -S "$user/$pass@$database as sysdba" <<EOF
	SET SERVEROUTPUT ON;
   SET FEEDBACK OFF;
	DECLARE
		v_restore_point_name VARCHAR2(100):='';
	BEGIN
		SELECT name INTO v_restore_point_name FROM V\$RESTORE_POINT WHERE name LIKE '%$alias%';
		IF v_restore_point_name IS NOT NULL THEN
			DBMS_OUTPUT.PUT_LINE(v_restore_point_name);
		ELSE
			DBMS_OUTPUT.PUT_LINE('');
		END IF;
	END;
	/
	EXIT;
EOF
)
echo $restore_point_name
}

########################
# get_restore_point_name "sys" "oracle" "fcclive" "PREEOD_R1_FCCLIVE"
#
########################
function get_restore_point_scn() {
   local user="$1"
   local pass="$2"
   local databse="$3"
	local alias="$4"
	local restore_point_name=""
	restore_point_scn=$(sqlplus -S "$user/$password@$database as sysdba" <<EOF
	SET SERVEROUTPUT ON;
   SET FEEDBACK OFF;
	DECLARE
		v_restore_point_scn VARCHAR2(100):='';
	BEGIN
		SELECT scn INTO v_restore_point_scn FROM V\$RESTORE_POINT WHERE name LIKE '%$alias%';
		IF v_restore_point_scn IS NOT NULL THEN
			DBMS_OUTPUT.PUT_LINE(v_restore_point_scn);
		ELSE
			DBMS_OUTPUT.PUT_LINE('');
		END IF;
	END;
	/
	EXIT;
EOF
)
echo $restore_point_scn
}

########################
# check_restore_point "sys" "oracle" "fcclive" "PREEOD_R1_FCCLIVE"
########################
function check_restore_point() {
   local user="$1"
   local password="$2"
   local service="$3"
   local restore_point_name="$4"
   message=$(sqlplus -S "$user/$pass@$db as sysdba" <<EOF
      SET SERVEROUTPUT ON;
      SET FEEDBACK OFF;
      SET
      DECLARE
         v_restore_point_name VARCHAR2(100):='';
      BEGIN
         SELECT name INTO v_restore_point_name FROM V\$RESTORE_POINT WHERE name LIKE '%$restore_point_name%';
         IF v_restore_point_name IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE(v_restore_point_name);
         ELSE
            DBMS_OUTPUT.PUT_LINE('Restore point not existed');
         END IF;
      END;
      /
      EXIT;
EOF
)
echo $message
}

########################
# check_restore_point "sys" "oracle" "fcclive" "PREEOD_R1_FCCLIVE"
########################

