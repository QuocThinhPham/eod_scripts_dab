#!/bin/bash

. /home/oracle/db10g_env fccreport

# Get name of restore point
rp_name=$(sqlplus -S "/ as sysdba" << EOF
set echo off feedback off heading off lines 200 pages 0
select name from v\$restore_point;
exit;
EOF
)

# Revert to physical standby
sqlplus -S "/ as sysdba" << EOF > /home/oracle/shell_scripts/revert_to_physical_standby.log

shutdown immediate;

startup mount;

flashback database to restore point $rp_name;

alter database convert to physical standby;

alter system set dg_broker_start=true scope=both sid='*';

shutdown immediate;

startup mount;

exit;
EOF
