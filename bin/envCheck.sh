#/bin/bash
version=0.5
###########################################################
#	Script : envCheck
#   0.1	    Initial version for TM
#   0.2     Added esbMonitor
#   0.3	    Added pccsClaim
#   0.4     Whirlpool Check added
#   0.5     REST check
###########################################################
#######################################
## Location of system binaries
#######################################
AWK=$(command -v awk)
CAT=$(command -v cat)
CHMOD=$(command -v chmod)
CUT=$(command -v cut)
DATE=$(command -v date)
GREP=$(command -v grep)
SED=$(command -v sed)
SLEEP=$(command -v sleep)
TAIL=$(command -v tail)
TEE=$(command -v tee)
UNIQ=$(command -v uniq)

#######################################
## CONSTANTS
#######################################
# dateTime=`date +%d-%m-%Y-%H-%M-%S`
dateTime=`date +%Y%m%d`
dir=/was/dgadmin/logs/envCheck
file=envCheck
logFile=$dir/$file-$dateTime.log

timeHours=`date +%H%M%S | cut -c1-2`
timeMin=`date +%H%M%S | cut -c3-4`
timeLog=$timeHours":"$timeMin

wikiDir=/was/jspwiki/appsup/storage
uuid=${2}
wikiFile=Check.txt

if [ ! -d ${dir} ]; 
then
	mkdir ${dir}
fi 

if [ "$(id -u)" = "1000" ]; then
	#id wasadm | sed 's/uid=\([0-9]*\).*/\1/g'
	echo " Changing permissions"
	chmod 666 ${logFile}
fi

echo "--------------------------"   | tee -a ${logFile}
echo "  Env check for MW at     "   $timeHours":"$timeMin   | tee -a ${logFile}
echo "--------------------------"   | tee -a ${logFile}

## NODE 1
###########

echo " -->  COMMENCING ACE PROD NODE 1 " | tee -a ${logFile}
echo " -->> Checking Disk Space -- N1  " | tee -a ${logFile}
echo " ############################### " | tee -a ${logFile}
ssh mqbrkr@lonlprdesb001 df -h           | tee -a ${logFile}
sleep 5 

echo " -->> Checking WMQ -- NODE1 (Last completed report)  " | tee -a ${logFile}
echo " ################################################### " | tee -a ${logFile}
#Get
ONEBUTLASTMQSHOW=`ssh mqbrkr@lonlprdesb001 cat /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log|cut -d ":" -f1-2|uniq|tail -2|head -1`
ssh mqbrkr@lonlprdesb001 cat /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log|grep "${ONEBUTLASTMQSHOW}"|tee -a ${logFile}
##
#ssh mqbrkr@lonlprdesb001 tail /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log | tee -a ${logFile}
##
sleep 5

echo " -->> Checking running ISes -- NODE 1  " | tee -a ${logFile}
echo " ##################################### " | tee -a ${logFile}
ssh mqbrkr@lonlprdesb001 ps -fumqbrkr | grep -i dataflowengine| sort | tee -a ${logFile}
RUNNING_IS_TOTAL=`ssh mqbrkr@lonlprdesb001 ps -fumqbrkr | grep -i dataflowengine| sort | wc -l`
echo "Total: ${RUNNING_IS_TOTAL}"|tee -a ${logFile}

sleep 5

echo " -->> Checking DB conns (& other esbMonitor stats) -- N1  " | tee -a ${logFile}
echo " ######################################################## " | tee -a ${logFile}

#ssh mqbrkr@lonlprdesb001 tail /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log | tee -a ${logFile}
ESBMONITORLASTPID=`ssh mqbrkr@lonlprdesb001 cat /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log|grep "Ended"|tail -1|awk '{print $3}'`
ssh mqbrkr@lonlprdesb001 cat /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log|grep "${ESBMONITORLASTPID}"|tee -a ${logFile}
sleep 5

echo " -->> Checking memory usage (for top 10)  -- N1  " | tee -a ${logFile}
echo " ############################################### " | tee -a ${logFile}
ssh mqbrkr@lonlprdesb001 /home/mqbrkr/dgadmin/bin/pMem   | tee -a ${logFile}
sleep 10

echo " --> PccsClaim check "
/was/dgadmin/bin/testwebsvcs_proxy.sh PRD SOAP PccsClaim |tee -a ${logFile}
sleep 5

## NODE 2
###########

echo " -->  *** COMMENCING ACE PROD NODE 2 *** " | tee -a ${logFile}
echo " --> Whirlpool check "                     | tee -a ${logFile}
ssh mqbrkr@lonlprdesb002 cat /home/mqbrkr/dgadmin/logs/whirlpoolCheck/whirlpoolCheck-$dateTime.log | tail -12 | tee -a ${logFile}
sleep 5

echo " -->> Checking Disk Space -- NODE 2  " | tee -a ${logFile}
echo " ################################### " | tee -a ${logFile}

ssh mqbrkr@lonlprdesb002 df -h | tee -a ${logFile}
sleep 5

echo " -->> Checking WMQ -- NODE 2 (Last completed report)  " | tee -a ${logFile}
echo " #################################################### " | tee -a ${logFile}
ONEBUTLASTMQSHOW=`ssh mqbrkr@lonlprdesb002 cat /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log|cut -d ":" -f1-2|uniq|tail -2|head -1`
ssh mqbrkr@lonlprdesb002 cat /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log|grep "${ONEBUTLASTMQSHOW}"|tee -a ${logFile}
#ssh mqbrkr@lonlprdesb002 tail /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log | tee -a ${logFile}
sleep 5

echo " -->> Checking running ISes -- NODE 2  " | tee -a ${logFile}
echo " ##################################### " | tee -a ${logFile}

ssh mqbrkr@lonlprdesb002 ps -fumqbrkr | grep -i dataflowengine | tee -a ${logFile}
RUNNING_IS_TOTAL=`ssh mqbrkr@lonlprdesb002 ps -fumqbrkr | grep -i dataflowengine|wc -l`
echo "Total: ${RUNNING_IS_TOTAL}"|tee -a ${logFile}
sleep 5

echo " --> Checking DB connections (& other esbMonitor stats) -- N2"
#ssh mqbrkr@lonlprdesb002 tail /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log | tee -a ${logFile}
ESBMONITORLASTPID=`ssh mqbrkr@lonlprdesb002 cat /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log|grep "Ended"|tail -1|awk '{print $3}'`
ssh mqbrkr@lonlprdesb002 cat /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log|grep "${ESBMONITORLASTPID}"|tee -a ${logFile}
sleep 5

echo " -->> Checking memory usage (for top 10)  -- NODE 2  " | tee -a ${logFile}
echo " ############################################### " | tee -a ${logFile}
ssh mqbrkr@lonlprdesb002 /home/mqbrkr/dgadmin/bin/pMem   | tee -a ${logFile}
sleep 10

## NODE 3
###########

echo " -->  COMMENCING ACE PROD NODE 3 " | tee -a ${logFile}
echo " -->> Checking Disk Space -- N3  " | tee -a ${logFile}
echo " ############################### " | tee -a ${logFile}
ssh mqbrkr@lonlprdesb003 df -h           | tee -a ${logFile}
sleep 5 

echo " -->> Checking WMQ -- NODE3 (Last completed report)  " | tee -a ${logFile}
echo " ################################################### " | tee -a ${logFile}
#Get
ONEBUTLASTMQSHOW=`ssh mqbrkr@lonlprdesb003 cat /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log|cut -d ":" -f1-2|uniq|tail -2|head -1`
ssh mqbrkr@lonlprdesb003 cat /home/mqbrkr/dgadmin/logs/showMQQsWithMessages/showMQQsWithMessages_$dateTime.log|grep "${ONEBUTLASTMQSHOW}"|tee -a ${logFile}
sleep 5


echo " -->> Checking running ISes -- NODE 3  " | tee -a ${logFile}
echo " ##################################### " | tee -a ${logFile}
ssh mqbrkr@lonlprdesb003 ps -fumqbrkr | grep -i dataflowengine| sort | tee -a ${logFile}
RUNNING_IS_TOTAL=`ssh mqbrkr@lonlprdesb003 ps -fumqbrkr | grep -i dataflowengine| sort | wc -l`
echo "Total: ${RUNNING_IS_TOTAL}"|tee -a ${logFile}

sleep 5

echo " -->> Checking DB conns (& other esbMonitor stats) -- N3  " | tee -a ${logFile}
echo " ######################################################## " | tee -a ${logFile}

ESBMONITORLASTPID=`ssh mqbrkr@lonlprdesb003 cat /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log|grep "Ended"|tail -1|awk '{print $3}'`
ssh mqbrkr@lonlprdesb003 cat /home/mqbrkr/dgadmin/logs/esbMonitor/esbMonitor_$dateTime.log|grep "${ESBMONITORLASTPID}"|tee -a ${logFile}
sleep 5

echo " -->> Running external REST check !!   " | tee -a ${logFile}
echo " ##################################### " | tee -a ${logFile}
/was/dgadmin/bin/testwebsvcs_proxy.sh PRD REST | tee -a ${logFile}
