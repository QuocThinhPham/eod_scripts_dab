# Login Information
USER="sys"
PASSWORD="oracle"

# Service
PRIM_SVC="fcclive"
STB1_SVC="fccreport"
STB2_SVC="fccstandby"

# Name Restore Point
RP_NAME_PRIM="EOD_RP_PRIM"
RP_NAME_STB="EOD_RP_STB"

# Enviroment file
. /home/oracle/db10g_env $PRIM_SVC

# Log file
LOG_FILE="/home/oracle/huyth/out2.log"




# /home/monitor/script
# pre-eod.sh tao log co ngay thang nam, gio + goi toi file .pre de chay  (file log user oracle)
# + kiem tra xem log ton tai chua. Neu ton tai khong cho chay, goi dba. Xoa log chay lai      /log-eod

