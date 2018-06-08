
#!/bin/bash
# Author: SaravAK
# Purpose: LogRotation of .out files
#
BASEDIR=`dirname $0`
DIRTOSEARCH="/opt/tomcat /apps/tomcat /apps/weblogic /opt/weblogic"
for DIR in $DIRTOSEARCH
do
        echo -e "\nProcessing the Directory $DIR"
        echo -e "$DIR"
        RESULTSET=`find $DIR -name "*.out" 2>/dev/null`
        if [ `echo $RESULTSET|wc -l` -gt 0 ]
        then
                for OUTFILE in ${RESULTSET}
                do
                        echo "--Rotating the LogFile",$OUTFILE
                        echo "---------------------------------"
                        sed "s/REPLACELOGFILE/`echo $OUTFILE|sed -f front2back.sed`/g" logrotate-out.conf-template  > logrotate-tomcat.conf
                        logrotate -f logrotate-out.conf
                        echo "---------------------------------"
                        echo "--LogRotation Completed for $OUTFILE"
                        ls -lrt $OUTFILE*
                done
        else
                echo -e "No *.out files found in the directory $DIR"
        fi
done
