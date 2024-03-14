# Login Information
USER="sys"
PASSWORD="oracle123"

# Service
PRIM_SVC="mydb"
STB1_SVC="mydbstb"
STB2_SVC="mydbstb2"

# Name Restore Point
RP_NAME_PRIM="EOD_RP_PRIM"
RP_NAME_STB="EOD_RP_STB"

# Enviroment file
. /home/oracle/db10g_env $PRIM_SVC

# Log file
LOG_FILE="/home/oracle/out2.log"