#!/bin/bash
# Author: SaravAK
# Purpose: LogRotation&LogPurging
# Name: diskspaceman.sh
#

# DECLARATIONS
BASEDIR=`dirname $0`
DIRTOSEARCH="/opt/tomcat/instances/*/logs /apps/tomcat/instances/*/logs /apps/weblogic/domains/*/*/*/logs /opt/weblogic/domains/*/*/*/logs"
LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null`
FILEDATE=`date +%d%m%y%H%M%S`
LOGDATE=`date +%d-%m-%y' '%H':'%M':'%S`

if [ $# -ne 1 ]
then
        echo -e "Please execute the script correctly"
        echo "./diskspaceman.sh -retentionperiod=400days"
        exit
fi

if [ `echo $1|cut -d "=" -f1` == "-retentionperiod" ]
then
        RETENTION=`echo $1|cut -d "=" -f2|awk -F "days" '{print $1}'`
        echo $RETENTION
else
        echo "FAIL"
        exit
fi

LOG()
{
        echo -e "$LOGDATE $@"
}

LOGROTATE()
{
        for OUTFILE in $@
        do
                sed "s/REPLACELOGFILE/`echo $OUTFILE|sed -f $BASEDIR/front2back.sed`/g" $BASEDIR/logrotate-out.conf-template  > $BASEDIR/logrotate-tomcat.conf
                logrotate -f $BASEDIR/logrotate-out.conf
                if [ $? -eq 0 ]
                then
                        LOG "-- LOGROTATION COMPLETED SUCCESSFULLY FOR $OUTFILE"
                else
                        LOG "-- LOGROTATION FAILED FOR $OUTFILE"
                fi
        done
}


PURGE()
{
        FILETOREMOVE=`find . -type f -mtime +$RETENTION`
        LOG "REMOVING THE $RETENTION DAYS OLD FILES"
        LOG "LIST OF FILES GOING TO BE REMOVED: [ `echo $FILETOREMOVE|sed 's/ /,/g' ` ]"
        find . -type f -mtime +$RETENTION -exec rm -vf {} \;  >> /tmp/diskspaceman-removedlist-$FILEDATE 2>&1
}

#MAIN - START

LOG "==============================="
LOG "DISKSPACEMAN - PROCESS STARTED"
LOG "==============================="

LOG "LIST OF DIRECTORIES FOUND: [ `echo $LOGSDIRS|sed 's/ /,/g' ` ]"
for DIR in $LOGSDIRS
do
        LOG
        LOG
        LOG "==========================================================="
                # INTO THE DIRECTORY
                cd $DIR
        LOG "PROCESSING DIRECTORY: $DIR"
        LOG
        LISTOFFILES=`ls $DIR|egrep -i "*.log$|*.out$"`
        LOG "LIST OF FILES FOUND FOR LOGROTATION: [ `echo $LISTOFFILES|sed 's/ /,/g' ` ]"

        #Initiate Log Rotation for these files
        LOGROTATE $LISTOFFILES

                #PURGING PROCESS STARTS
                LOG
                LOG "PURGING PROCESS STARTED  "
                PURGE $DIR
                LOG "PURGING PROCESS COMPLETED"

                # OUT OF THE DIRECTORY
                cd $BASEDIR
        LOG "==========================================================="
done

