source ./db_utils.sh

function dropR1() {
    local user="$1"
    local password="$2"
    local service="$3"
    local rp_name="$4"
    result=$(sqlplus -S /nolog <<EOF
        connect $user/$password@$service as sysdba;
        set heading off;
        set pagesize 0;
        set feedback on;
        drop restore point $rp_name;
        exit;
EOF
)
echo "$result" | grep -q "Restore point dropped" > /dev/null
if [ $? -eq 0 ]; then
        echo "OK"
else
        echo "Failed"
fi
}

#dropR1 "sys" "oracle123" "orclstb" "R1_EOD"



# function dropRp() {
#     local restore_point_name="$1"
#     local message=""
#     if [ ${#restore_point_name} == 0 ]; then
#         echo "Restore point không tồn tại."
#     else
#     message=$(sqlplus -S "$user/$password@$database as sysdba" <<EOF 														
#     SET SERVEROUTPUT ON;
#     DECLARE
#         v_exists NUMBER;
#     BEGIN
#         SELECT COUNT(*) INTO v_exists FROM V\$RESTORE_POINT WHERE NAME = '$restore_point_name';
#         IF v_exists > 0 THEN
#             EXECUTE IMMEDIATE 'DROP RESTORE POINT $restore_point_name';
#             DBMS_OUTPUT.PUT_LINE('Drop restore point ($restore_point_name): Successfully.');
#         ELSE
#             DBMS_OUTPUT.PUT_LINE('Drop restore point: Failed.');
#         END IF;
#     END;
#     /
#     EXIT;
# EOF
# )
#     fi
#     echo $message
# }