########################
# get_current_scn "sys" "oracle" "fcclive"
########################
function get_current_scn() {
        local user="$1"
        local password="$2"
        local service="$3"
        result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set pagesize 0;
        set feedback off heading off verify off;
        select to_char(current_scn) from v\$database;
        exit;
EOF
)
        echo $current_scn
}

########################
# get_restore_point_scn "sys" "oracle" "fcclive" "PREEOD_R1_FCCLIVE"
########################
function get_restore_point_scn() {
        local user="$1"
        local password="$2"
        local service="$3"
        local restore_point_name="$4"
        result=$(sqlplus -S /nolog <<EOF >> /home/oracle/shell_scripts/v1/pre_eod.log
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback off;
        select to_char(scn) from v\$restore_point where name like '%$alias%';
        exit;
EOF
)
        echo $current_scn
}

########################
# compare_scn "sys" "oracle" "fcclive" "PREEOD_R1_FCCLIVE"
########################
function compare_scn() {
        local user="$1"
        local password="$2"
        local service="$3"
        local restore_point_name="$4"
        current_scn=$(get_current_scn "sys" "oracle" "fccreport")
        restore_point_scn=$(get_restore_point_scn "sys" "oracle" "fcclive" "PREEOD_R1_FCCREPORT")
        if [ $current_scn -eq $restore_point_scn ]; then
                echo "Equal"
        else
                echo "Not Equal"
        fi
}