#!/bin/bash
HOUR=`date | awk '{print $4}'`
DAY=`date | awk '{print $3}'`
MONTH=`date | awk '{print $2}'`
YEAR=`date | awk '{print $6}'`
# HOME="/home/monitor/scripts"
# LOG="/log-eod"
HOME="/home/oracle/huyth"
LOG="/home/oracle/huyth/log-eod"

if [ -e $LOG/pre-eod.log.$MONTH.$DAY.$YEAR ]; then
        echo "The pre-eod script has been run, Please don't rerun again!!!";
        echo -e "Please call to sys&dba!\n"
else
        # sudo $HOME/pre 2>&1 | tee $LOG/pre-eod.log.$MONTH.$DAY.$YEAR;
        echo "Pre-EOD: Create restore point is running..."
        echo "This operation will take a few moments."
        echo "The progress can be monitored: tail -300f $LOG/pre-eod.log.$MONTH.$DAY.$YEAR"
        $HOME/pre 2>&1 | tee $LOG/pre-eod.log.$MONTH.$DAY.$YEAR;
fi