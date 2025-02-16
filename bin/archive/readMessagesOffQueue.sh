#!/bin/bash
##############################################################
#       Title   :       readMessagesOfQueue.sh
#       Ver     :       1.0.2
#       By      :       Krzysztof Sokolowski
#       Desc    :       This script extracts messages from a given queue of a given Queue Manager.
#			This script takes two parametres:
#			$1 - Queue Name
#			$2 - Queue Manager Name
#                       
#       Version Control.
#       ----------------
#	Ver	1.0.2	KS	Completely reworked the message generation engine, as it was ommiting one message 
#	Ver 1.0.1 	KS	Added a check if the file with messages exist
#   Ver 1.0.0 	KS	Initial release
#               
##############################################################
checkOS ()
{
    SYS=`uname -o 2>/dev/null`

    if [ $? -eq 0 ]; then
        echo " --> in windows "
        macOS="FALSE"
    else
        echo " --> in macOS "
        macOS="TRUE"
    fi
}

usage()
{
    echo " ReadMessageOffQueue.sh <<queueName>> <<queueManagerName>> "
    echo ""
}

if [ "$#" -ne 2 ]; then
	echo " You have to pass in the correct parameters "
	usage
	exit 3;
fi


NOW=`date +%Y%m%d_%H%M`
TEMP_MESSAGES_FILE="/home/mqbrkr/temp/${1}_${NOW}_TMP.txt"
TEMP_MESSAGE_FILE="/home/mqbrkr/temp/message.tmp"
echo -n "" > ${TEMP_MESSAGES_FILE}
##echo "Temp message file: ${TEMP_MESSAGES_FILE}"
##echo "1 parametre: ${1}"
##echo "2 parametre: ${2}" 
#Drop messages to a temp file:
/opt/mqm/samp/bin/amqsbcg ${1} ${2} >> ${TEMP_MESSAGES_FILE}
#cat ${TEMP_MESSAGES_FILE}
TEMP_MESSAGE_FILE_LENGTH=`cat ${TEMP_MESSAGES_FILE}|wc -l|sed 's/ //g'`
##echo "TEMP_MESSAGE_FILE_LENGTH: ${TEMP_MESSAGE_FILE_LENGTH}"
MESSAGES_FILE="/home/mqbrkr/temp/${1}_${NOW}_Messages.txt"
#Get last message position
MESSAGE_START_LINE=""
MESSAGE_END_LINE=""
MESSAGE_NO=0
NUMBER_OF_MESSAGES=`cat ${TEMP_MESSAGES_FILE}|grep -n "Message descriptor"|cut -d : -f1|wc -l`
START_OF_MESSAGE_COUNT=1; 	#This is the iterating count of message beginnings 
END_OF_MESSAGE_COUNT=2;		#This is the iterating count of message endings
while [ ${START_OF_MESSAGE_COUNT} -le ${NUMBER_OF_MESSAGES} ]; do
	MESSAGE_START_LINE=`cat ${TEMP_MESSAGES_FILE}|grep -n "Message descriptor"|cut -d : -f1|head -${START_OF_MESSAGE_COUNT}|tail -1`
	MESSAGE_END_LINE=`cat ${TEMP_MESSAGES_FILE}|grep -n "Message descriptor"|cut -d : -f1|head -${END_OF_MESSAGE_COUNT}|tail -1`
	if [ ${START_OF_MESSAGE_COUNT} -lt ${NUMBER_OF_MESSAGES} ]; then
		echo "Processing message ${START_OF_MESSAGE_COUNT}"
		##echo "Message ${START_OF_MESSAGE_COUNT}; Start line: ${MESSAGE_START_LINE}; End line: ${MESSAGE_END_LINE}"
	else
		echo "Processing message ${START_OF_MESSAGE_COUNT} (last message)"
		MESSAGE_END_LINE=${TEMP_MESSAGE_FILE_LENGTH}
		##echo "Message ${START_OF_MESSAGE_COUNT}; Start line: ${MESSAGE_START_LINE}; End line: ${MESSAGE_END_LINE}"
	fi

	##echo "TEMP_MESSAGE_FILE_LENGTH: ${TEMP_MESSAGE_FILE_LENGTH}"
        ##echo "MESSAGE_START_LINE: ${MESSAGE_START_LINE}"
        SHOW_LAST_NUMBER_OF_LINES=`expr ${TEMP_MESSAGE_FILE_LENGTH} - ${MESSAGE_START_LINE} + 2`
        ##echo "SHOW_LAST_NUMBER_OF_LINES: ${SHOW_LAST_NUMBER_OF_LINES}"
        ##echo "MESSAGE_END_LINE: ${MESSAGE_END_LINE}"
        MESSAGE_LENGTH=`expr ${MESSAGE_END_LINE} - ${MESSAGE_START_LINE}`
        ##echo "MESSAGE_LENGTH: ${MESSAGE_LENGTH}"
        MESSAGE_NO=`expr ${MESSAGE_NO} + 1`
        ##echo "MESSAGE_NO: ${MESSAGE_NO}"
        echo "###" >> ${MESSAGES_FILE}
        echo "Message number: ${MESSAGE_NO}"  >> ${MESSAGES_FILE}
        echo "Message descriptor:" >> ${MESSAGES_FILE}
        ##echo "Extracting message number: ${MESSAGE_NO}"
        #Extract single message to temp file
        cat ${TEMP_MESSAGES_FILE}|tail -${SHOW_LAST_NUMBER_OF_LINES}|head -${MESSAGE_LENGTH} > ${TEMP_MESSAGE_FILE}
        cat ${TEMP_MESSAGE_FILE}|egrep ^" "|head -26 >> ${MESSAGES_FILE}
        echo "Message:" >> ${MESSAGES_FILE}
        for LINE in `cat ${TEMP_MESSAGE_FILE}|egrep ^[0-9A-Z]\{\8}|cut -d "'" -f2`; do
                echo -n "${LINE}" >> ${MESSAGES_FILE}
        done
        echo -e "\n" >> ${MESSAGES_FILE}

	START_OF_MESSAGE_COUNT=`expr ${START_OF_MESSAGE_COUNT} + 1`
	END_OF_MESSAGE_COUNT=`expr ${END_OF_MESSAGE_COUNT} + 1`
done

if [ -f ${MESSAGES_FILE} ]; then
	echo "Messages saved to: ${MESSAGES_FILE}"
	#rm ${TEMP_MESSAGES_FILE}
else
	echo "ERROR: Messages file has not been created"
	exit 1
fi
if [ -f ${TEMP_MESSAGES_FILE} ]; then
        rm ${TEMP_MESSAGES_FILE}
        ##if [ $? -eq 0 ]; then
        ##        echo "Temporary message file ${TEMP_MESSAGES_FILE} removed"
        ##else
        ##        echo "No temporary messages file ${TEMP_MESSAGES_FILE} to delete"
        ##fi
fi
