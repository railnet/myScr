#!/bin/sh

# switch application monitor
scriptVersion=0.2

# file script names for supported nodes
#script_name_ecn320=specSwitchMon.sh # not used in this version
#script_name_ecn330=specSwitchMon.sh # not used in this version

# node monitor file log name and related ext
runTimeS=$(date +%Y%m%dh%H%M%S)
fname320="sw320mon_"$runTimeS
fname330="sw330mon_"$runTimeS
fname120="sw120mon_"$runTimeS
fexte=".log"

# main script file log name and related ext
fnameMain="switchMonSession"
fexte=".log"

# trap handler for background run
trap '' SIGHUP

# input params processing
defParams=0

# input error code
interror=0

# fromEMP_SBC
fromEMPSBC=1

###########################################################

# number of loops or default (D) params
if [ -n "$1" ]
then
 if ( echo $1 | grep D >/dev/null)
 then
	case "$1" in
		"D1h"|"D1d"|"D1w"|"D1m"|"DbgNodeCheck")
				defParams=1
				numlogname=2
				msz=400
	    ;;
		*) interror=1;;
	esac
 else
	lp=$1
  fi
else
 if [ "$interror" -eq 0 ]
	then 
		interror=1
 fi
fi
###########################################################
# wait between two loops
if [ "$defParams" -eq 0 ]
then
if [ -n "$2" ]
then
  slp=$2 
else
 if [ "$interror" -eq 0 ]
	then 
		interror=2;
 fi
fi
fi
###########################################################
if [ "$defParams" -eq 0 ]
then
if [ -n "$3" ]
then
 numlogname=$3 
else
 if [ "$interror" -eq 0 ]
  then 
	interror=3;
 fi
fi
fi
###########################################################
if [ "$defParams" -eq 0 ]
then
if [ -n "$4" ]
then
 msz=$4 
else
 if [ "$interror" -eq 0 ]
	then 
		interror=4;
 fi
fi
fi
###########################################################
if [ "$defParams" -eq 0 ]
then
if [ -n "$5" ]
then
 nodetp=$5
 case "$nodetp" in
	"ECN320") 
			  fname=$fname320
			  loopduration=45
			  fromEMPSBC=1
	;;
	"ECN330") 
			  fname=$fname330
			  loopduration=20
			  fromEMPSBC=1
	;;
	"EMN120") 
			  fname=$fname120
			  loopduration=5
			  fromEMPSBC=0
    ;;
	*) echo "  $5 Node not supported !!!"
	        interror=5;
	;;
  esac
else
 if [ "$interror" -eq 0 ]
	then 
	 interror=5;
 fi
fi
fi
###########################################################
if [ "$defParams" -eq 0 ]
then
if [ -n "$6" ]
then
 nodeIp=$6
else
 if [ "$interror" -eq 0 ]
	then 
		interror=6;
 fi
fi
fi
###########################################################
if [ "$defParams" -eq 0 ]
then
if [ -n "$7" ]
then
 monPort=$7
else
 if [ "$interror" -eq 0 ]
	then 
		interror=7;
 fi
fi
fi
###########################################################

if [ "$defParams" -eq 1 ]
then
	# Node Type check
	rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.1.1.0"
	result=$( $rst | cut -d' ' -f 4 )
	nodetp=$( echo $result | cut -d';' -f 1 | cut -d'"' -f 2)
	#echo $nodetp
	case $nodetp in
		*"ECN330"*)  
			#scrpname=$script_name_ecn330
			fname=$fname330
			loopduration=20
			slp=120
			grepstr='# ## 330 ##'
			case $1 in
				"D1h")
					lp=26
				;;
				"D1d")
					lp=615
				;;
				"D1w")
					lp=4320
				;;
				"D1m")
					lp=18500
				;;
				"DbgNodeCheck")
					echo "This node is ECN330"
					#echo "The following folder will be created: "$fname
					exit 0
				;;
				*) echo "Default collection not valid"
				;;
			esac
		;;
		*"ECN320"*)
			#scrpname=$script_name_ecn320
			fname=$fname320
			loopduration=45
			slp=120
			grepstr='# ## 320 ##'
			case $1 in
				"D1h")
					lp=22
				;;
				"D1d")
					lp=525
				;;
				"D1w")
					lp=3660
				;;
				"D1m")
					lp=15700
				;;
				"DbgNodeCheck")
					echo "This node is ECN320"
					#echo "The following folder will be created: "$fname
					exit 0
				;;
				*) echo "Default collection not valid"
				;;
			esac
		;;
		*)  echo "ERROR on node type reading!"
			exit 0
		;;
	esac
fi

if !(echo "$lp" | grep '[0-9]' >/dev/null) || 
   !(echo "$slp" | grep '[0-9]' >/dev/null) ||
   !(echo "$numlogname" | grep '[0-9]' >/dev/null) ||
   !(echo "$msz" | grep '[0-9]' >/dev/null)
then
 interror=10
 echo "       Error!! Invalid paramater"
fi

if [ "$interror" -gt 0 ]
then
 echo "Usage: name [D][L S F K T]"
 echo "       L = number of loops"
 echo "       S = sleep seconds among the loops"
 echo "       F = number of log files to generate"
 echo "       K = max kilobytes for each log file"
 echo "       T = node type (ECN320 / ECN330 / EMN120)"
 echo "       A = node address (IP)"
 echo "       P = port id"
 echo "       D = default collection parameters with automatic node type discovery:"
 echo "           D1h = L=22/26 S=120 F=2 K=400 T=ECN330/ECN320 (~1 hour test)"
 echo "           D1d = L=525/615 S=120 F=2 K=400 T=ECN330/ECN320 (~1 day test)"
 echo "           D1w = L=3660/4320 S=120 F=2 K=400 T=ECN330/ECN320 (~1 week test)"
 echo "           D1m = L=15700/18500 S=120 F=2 K=400 T=ECN330/ECN320 (~1 month test)"
 echo "       dbgNodeCheck = it will automatically check the node type and it will stop immediately - valid only for ECN3x0 nodes"
 echo ""
 echo "Output log files: a folder named with the system date will contain the log files generated by the script."

	case "$interror" in
	"1")  echo "       Please, input L or D";;
	"2")  echo "       Please, input S";;
	"3")  echo "       Please, input F";;
	"4")  echo "       Please, input K";;
	"5")  echo "       Please, input T";;
	esac
	exit 0
fi

#echo "The node is: "$nodetp
#echo "script file "$scrpname
#echo "fname "$fname
#echo "loopdur "$loopduration
#echo "lp "$lp
#echo "slp "$slp
#echo "msz "$msz
#echo "numlogname " $numlogname


# file log path
if [ "$fromEMPSBC" -eq 1 ]
then
	pathbase="/var"
else
	pathbase="."
fi

#pathcheck=$(echo $(pwd))
if [ "$fromEMPSBC" -eq 1 ]
then
	if !( pwd | grep $pathbase >/dev/null)
	then
		echo ""
		echo " ERROR!!! The scrip must be copied and launched at $pathbase folder"
		echo ""
		exit 0
	fi
fi
# input parameters check - end
##################################

# log folder creation
fldname=$nodetp$(date +%Y%m%dh%H%M%S)
path=$pathbase"/$fldname/"
pathFld=$pathbase"/$fldname"
cd $pathbase
mkdir $fldname

waitbeforetheloop=$(($slp+$loopduration))
maxsize=$(($msz*1024));
logname=$path$fname$fexte
lognameExt=$path$fname
lognametag=0
size=0

if [ "$fromEMPSBC" -eq 1 ]
then
	echo "nodo:"$(ifconfig | grep addr)
fi

lognameMain=$path$fnameMain$fexte

echo "##### ##### ###### ###### ##### #####" >> $lognameMain
echo "main script started on "$runTimeS" with PID:"$$ >> $lognameMain
echo "script version: "$scriptVersion >> $lognameMain
echo "input params:" >> $lognameMain
echo "   number of loops: "$lp >> $lognameMain
echo "   sleep seconds among the loops: "$slp >> $lognameMain
echo "   number of log files to generate: "$numlogname >> $lognameMain
echo "   max kilobytes for each log file: "$msz >> $lognameMain
echo "   node type: "$nodetp >> $lognameMain
if [ "$fromEMPSBC" -eq 1 ]
	then
		echo "node identity: " >> $lognameMain
		echo ""$(ifconfig | grep addr) >> $lognameMain
	else
	echo "node identity: "$nodeIp >> $lognameMain
fi

#echo "specific script called: $scrpname $lp $slp >> $logname" >> $lognameMain
#echo "##### script content: $scrpname #####" >> $lognameMain
#cat $scrpname | grep '$grepstr' >> $lognameMain
#echo "script content: $scrpname $lp $slp >> $logname" >> $lognameMain
let "tmp=$lp*($loopduration+$slp)"
echo "extimated duration is: $tmp secs." >> $lognameMain
echo "main script is running or it has been stopped (you can check with cmd: ps -aux | grep "$$")" >> $lognameMain

cat $lognameMain
echo "Logs will be stored in the following folder: "$path

#chmod 555 $scrpname
#./$scrpname $lp $slp $nodetp >> $logname
#echo main script pid: $$
#echo "$scrpname pid       : $(pidof $scrpname | cut -d' ' -f 1)"
#echo "$scrpname pid       : $(pidof $scrpname | cut -d' ' -f 1)" >> $lognameMain

let "numlogname -= 1" # number of log files 

#######################################################################
#######################################################################
#######################################################################

loops=$lp
secnds=$slp
snmpgetcounter=0
num=1

case $nodetp in
	"ECN330")
		#########################################
		# ECN330 monitor
		#########################################
		 
		 runTimeS=$(date +%Y%m%dh%H%M%S)
		 echo "START - pid $$ - start $nodetp EMP linux $runTimeS" >> $logname
		 ########################
		 while [ "$num" -le $loops ]
		 do
		  echo "L[$num]/[$loops] s" >> $logname
		  # Current Time                                                                        # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.10.1.6.2.0";      # ## 330 ##
		  echo "[TS] $( $rst | cut -d'"' -f 2 ) - $(date +%H%M%S)" >> $logname                  # ## 330 ##
		  # SysUpTime                                                                           # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.1.3.0"                        # ## 330 ##
		  echo "[UT] $($rst | cut -d' ' -f 5-7 )" >> $logname                                   # ## 330 ##
		  # Port 28 admin and oper status                                                       # ## 330 ##
		  rstAs="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.7.28";                # ## 330 ##
		  rstOs="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.8.28";                # ## 330 ##
		  echo "P[28] As:$( $rstAs | cut -d: -f 2 ) Os:$( $rstOs | cut -d: -f 2 )" >> $logname  # ## 330 ##
		  # Temperature                                                                         # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.600.1.1.3.2.0";        # ## 330 ##
		  echo "[Temp] $( $rst | cut -d: -f 2 )" >> $logname                                    # ## 330 ##
		  # The no. of ARP request sent by ARP process                                          # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.30.1.1.3.1.0";    # ## 330 ##
		  echo "[Arqs] $( $rst | cut -d: -f 2 )" >> $logname                                    # ## 330 ##
		  # The no. of ARP request received by ARP process                                      # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.30.1.1.3.2.0";    # ## 330 ##
		  echo "[Arqr] $( $rst | cut -d: -f 2 )" >> $logname                                    # ## 330 ##
		  # The no. of ARP reply sent by ARP process                                            # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.30.1.1.3.3.0";    # ## 330 ##
		  echo "[Arps] $( $rst | cut -d: -f 2 )" >> $logname                                    # ## 330 ##
		  # The no. of ARP reply received by ARP process                                        # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.30.1.1.3.4.0";    # ## 330 ##
		  echo "[Arpr] $( $rst | cut -d: -f 2 )" >> $logname                                    # ## 330 ##
			 
		  numsnmpgetbetweensleep=26
		  
		  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27    # ## 330 ##
			do
			prt=$i
				# Octect                                                                      # ## 330 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.6."$prt;    # ## 330 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.10."$prt;   # ## 330 ##
				echo "P[$prt] O:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname # ## 330 ##
				# Unicast                                                                     # ## 330 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.7."$prt;    # ## 330 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.11."$prt;   # ## 330 ##
				echo "P[$prt] U:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname # ## 330 ##
				# Multicast                                                                   # ## 330 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.8."$prt;    # ## 330 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.12."$prt;   # ## 330 ##
				echo "P[$prt] M:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname # ## 330 ##
				# Broadcast                                                                   # ## 330 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.9."$prt;    # ## 330 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.13."$prt;   # ## 330 ##
				echo "P[$prt] B:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname # ## 330 ##
				# Discard                                                                     # ## 330 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.13."$prt;      # ## 330 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.19."$prt;      # ## 330 ##
				echo "P[$prt] D:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname # ## 330 ##
				# Error                                                                       # ## 330 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.14."$prt;      # ## 330 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.20."$prt;      # ## 330 ##
				echo "P[$prt] E:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname # ## 330 ##
				# Unknown Protocol                                                            # ## 330 ##
				rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.15."$prt;       # ## 330 ##
				echo "P[$prt] IUp:$( $rst | cut -d: -f 2 )" >> $logname                       # ## 330 ##
				
				if [ $snmpgetcounter -eq $numsnmpgetbetweensleep ]
				then
					sleep 1
					snmpgetcounter=0 
				fi
				let "snmpgetcounter += 13"
			done # for
			
		nvln=1
		numsnmpgetbetweensleep=50

		# Available Bridge Mac Addr Count                                                     # ## 330 ##
		rstAM="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.10.1.1.8.6.0";  # ## 330 ##
		result="V[AM] $( $rstAM | cut -d' ' -f 4 )"                                           # ## 330 ##
		echo $result >> $logname                                                              # ## 330 ##

		# while [ "$nvln" -le 4094 ]
		#	do
		#		# Dynamic Mac Addr Count                                                                      # ## 330 ##
		#		rstDM="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.10.1.1.8.5.1.2.$nvln";  # ## 330 ##
		#		# Total Mac Addr Count                                                                        # ## 330 ##
		#		rstTM="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.10.1.1.8.5.1.4.$nvln";  # ## 330 ##
		#		result="V[$nvln] $( $rstDM | cut -d' ' -f 4 ) $( $rstTM | cut -d' ' -f 4 )"                   # ## 330 ##
		#		if !(echo $result | grep Such >/dev/null)
		#		then
		#			echo $result >> $logname
		#		fi
		#		let "nvln +=1"
		#		if [ $snmpgetcounter -eq $numsnmpgetbetweensleep ]
		#		then
		#			sleep 1
		#			snmpgetcounter=0 
		#		fi
		#		let "snmpgetcounter += 2"
		#	done

		  # Current Time                                                                      # ## 330 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.1400.10.1.6.2.0";    # ## 330 ##
		  echo "[TF] $( $rst | cut -d'"' -f 2 ) - $(date +%H%M%S)" >> $logname                # ## 330 ##
		  echo "L[$num]/[$loops] f" >> $logname # debug
		  ########################
		  let "num += 1"
		  sleep $secnds
		   ####################################################################
		   # Log files size monitor - start
		   ####################################################################
			 cmd=$(echo $(ls -la $path | grep $fname$fexte) | cut -d ' ' -f5)
			 let "size = $cmd"
			 if [ "$size" -gt "$maxsize" ]
			  then
				if [ "$lognametag" -le "$numlogname" ]
					then
						tag=$(($numlogname-$lognametag));
						cp -f "$logname" "$lognameExt.$tag$fexte";
						echo "" > $logname;
						let "lognametag += 1"
					else
						ttag=$numlogname
						while [ "$ttag" -ge 0 ]
						do
							let "ttag -= 1"
							if [ "$ttag" -ge 0 ]
							then 
								gtag=$(($ttag+1));
								cp -f "$lognameExt.$ttag$fexte" "$lognameExt.$gtag$fexte";
							else
								cp -f "$logname" "$lognameExt.0$fexte";
								echo "" > $logname;
							fi
						done
				fi
			 fi
		   ####################################################################
		   # Log files size monitor - end
		   ####################################################################
		 done # while
		 ########################
		 echo "END - $(date +%Y%m%dh%H%M%S)" >> $logname
		 ########################
	;;
	"ECN320")
		 #########################################
		 # ECN320 monitor from EMP 
		 #########################################
		 runTimeS=$(date +%Y%m%dh%H%M%S)
		 ########################
		 echo "START - pid $$ - start $nodetp EMP linux $runTimeS" >> $logname
		 ########################
		 while [ "$num" -le $loops ]
		 do
		  echo "L[$num]/[$loops] s" >> $logname
		  ########################

		  # Current Time                                                                              # ## 320 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.900.1.23.2.0";               # ## 320 ##
		  echo "[TS] $( $rst | cut -d'"' -f 2 ) - $(date +%H%M%S)" >> $logname                        # ## 320 ##
		  # SysUpTime                                                                                 # ## 320 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.1.3.0"                              # ## 320 ##
		  echo "[UT] $($rst | cut -d' ' -f 5-7 )" >> $logname                                         # ## 320 ##
		  
		  # Port 27 admin and oper status                                                             # ## 320 ##
		  rstAs="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.7.27";                      # ## 320 ##
		  rstOs="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.8.27";                      # ## 320 ##
		  echo "P[27] As:$( $rstAs | cut -d: -f 2 ) Os:$( $rstOs | cut -d: -f 2 )" >> $logname        # ## 320 ##
		  
		  # Temperature                                                                               # ## 320 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.600.1.1.3.2.0";              # ## 320 ##
		  echo "[Temp] $( $rst | cut -d: -f 2 )" >> $logname                                          # ## 320 ##
		  
		  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27            # ## 320 ##
			do
			prt=$i
				#echo -n "loop $i porta = [$prt]" $'\n'                                               # ## 320 ##
				# Octect                                                                              # ## 320 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.6."$prt;            # ## 320 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.10."$prt;           # ## 320 ##
				echo "P[$prt] O:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname       # ## 320 ##
				# Unicast                                                                             # ## 320 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.7."$prt;            # ## 320 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.11."$prt;           # ## 320 ##
				echo "P[$prt] U:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname       # ## 320 ##
				# Multicast                                                                           # ## 320 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.8."$prt;            # ## 320 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.12."$prt;           # ## 320 ##
				echo "P[$prt] M:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname       # ## 320 ##
				# Broadcast                                                                           # ## 320 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.9."$prt;            # ## 320 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.31.1.1.1.13."$prt;           # ## 320 ##
				echo "P[$prt] B:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname       # ## 320 ##
				# Discard                                                                             # ## 320 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.13."$prt;              # ## 320 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.19."$prt;              # ## 320 ##
				echo "P[$prt] D:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname       # ## 320 ##
				# Error                                                                               # ## 320 ##
				rstI="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.14."$prt;              # ## 320 ##
				rstO="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.20."$prt;              # ## 320 ##
				echo "P[$prt] E:$( $rstI | cut -d: -f 2 )$( $rstO | cut -d: -f 2 )" >> $logname       # ## 320 ##
				# Unknown Protocol                                                                    # ## 320 ##
				rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.15."$prt; >> $logname   # ## 320 ##
				echo "P[$prt] IUp:$( $rst | cut -d: -f 2 )" >> $logname                               # ## 320 ##
				sleep 1
			done # for
		  # Current Time                                                                              # ## 320 ##
		  rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.900.1.23.2.0";               # ## 320 ##
		  echo "[TF] $( $rst | cut -d'"' -f 2 ) - $(date +%H%M%S)" >> $logname                        # ## 320 ##
		  echo "L[$num]/[$loops] f" >> $logname
		  let "num += 1"
		  sleep $secnds
		   ####################################################################
		   # Log files size monitor - start
		   ####################################################################
			 cmd=$(echo $(ls -la $path | grep $fname$fexte) | cut -d ' ' -f5)
			 let "size = $cmd"
			 if [ "$size" -gt "$maxsize" ]
			  then
				if [ "$lognametag" -le "$numlogname" ]
					then
						tag=$(($numlogname-$lognametag));
						cp -f "$logname" "$lognameExt.$tag$fexte";
						echo "" > $logname;
						let "lognametag += 1"
					else
						ttag=$numlogname
						while [ "$ttag" -ge 0 ]
						do
							let "ttag -= 1"
							if [ "$ttag" -ge 0 ]
							then 
								gtag=$(($ttag+1));
								cp -f "$lognameExt.$ttag$fexte" "$lognameExt.$gtag$fexte";
							else
								cp -f "$logname" "$lognameExt.0$fexte";
								echo "" > $logname;
							fi
						done
				fi
			 fi
		   ####################################################################
		   # Log files size monitor - end
		   ####################################################################
		 done # while
		 echo "END - $(date +%Y%m%dh%H%M%S)" >> $logname
	;;
	"EMN120")
		 #########################################
		 # EMN120 monitor from Linux server
		 #########################################
		 runTimeS=$(date +%Y%m%dh%H%M%S)
		 ########################
		 ########################
		 echo "START - pid $$ - start $nodetp $runTimeS" >> $logname
		 ########################
		 while [ "$num" -le $loops ]
		 do
		  echo "L[$num]/[$loops] s" >> $logname
		  ########################
		  # Current Time                                                                              # ## 120 ##
		  #rst="snmpget -On -v 2c -c public "$nodeIp" 1.3.6.1.4.1.193.72.900.1.23.2.0";               # ## 120 ##
		  #echo "[TS] $( $rst | cut -d'"' -f 2 ) - $(date +%H%M%S)" >> $logname                       # ## 120 ##
		  #exit 0
		  # SysUpTime                                                                                 # ## 120 ##
		  rst="snmpget -On -v 2c -c public "$nodeIp" 1.3.6.1.2.1.1.3.0"                               # ## 120 ##
		  echo "[UT] $($rst | cut -d' ' -f 5-7 )" >> $logname                                         # ## 120 ##
		  
		  rst="snmpget -On -v 2c -c public "$nodeIp" 1.3.6.1.2.1.17.2.15.1.10."$monPort               # ## 120 ##
		  echo "[CC] $($rst | cut -d' ' -f 4 )" >> $logname                                         # ## 120 ##

		  rst="snmpget -On -v 2c -c public "$nodeIp" 1.3.6.1.2.1.17.2.15.1.3."$monPort               # ## 120 ##
		  echo "[CS] $($rst | cut -d' ' -f 4 )" >> $logname                                          # ## 120 ##
		  
		  rst="snmpget -On -v 2c -c public "$nodeIp" 1.3.6.1.2.1.2.2.1.18."$monPort               # ## 120 ##
		  echo "[NU] $($rst | cut -d' ' -f 4 )" >> $logname                                          # ## 120 ##
		  
		  rst="snmpget -On -v 2c -c public "$nodeIp" 1.3.6.1.2.1.2.2.1.17."$monPort               # ## 120 ##
		  echo "[UN] $($rst | cut -d' ' -f 4 )" >> $logname                                          # ## 120 ##
		  
		  
		  
		  
		  # Port 27 admin and oper status                                                             # ## 320 ##
		  #rstAs="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.7.27";                      # ## 320 ##
		  #rstOs="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.2.1.2.2.1.8.27";                      # ## 320 ##
		  #echo "P[27] As:$( $rstAs | cut -d: -f 2 ) Os:$( $rstOs | cut -d: -f 2 )" >> $logname        # ## 320 ##
		  
		  # Temperature                                                                               # ## 320 ##
		  #rst="snmpget -On -v 2c -c public 10.0.100.2 1.3.6.1.4.1.193.72.600.1.1.3.2.0";              # ## 320 ##
		  #echo "[Temp] $( $rst | cut -d: -f 2 )" >> $logname                                          # ## 320 ##
		  
		  echo "L[$num]/[$loops] f" >> $logname
		  let "num += 1"
		  sleep $secnds
		   ####################################################################
		   # Log files size monitor - start
		   ####################################################################
			 cmd=$(echo $(ls -la $path | grep $fname$fexte) | cut -d ' ' -f5)
			 let "size = $cmd"
			 if [ "$size" -gt "$maxsize" ]
			  then
				if [ "$lognametag" -le "$numlogname" ]
					then
						tag=$(($numlogname-$lognametag));
						cp -f "$logname" "$lognameExt.$tag$fexte";
						echo "" > $logname;
						let "lognametag += 1"
					else
						ttag=$numlogname
						while [ "$ttag" -ge 0 ]
						do
							let "ttag -= 1"
							if [ "$ttag" -ge 0 ]
							then 
								gtag=$(($ttag+1));
								cp -f "$lognameExt.$ttag$fexte" "$lognameExt.$gtag$fexte";
							else
								cp -f "$logname" "$lognameExt.0$fexte";
								echo "" > $logname;
							fi
						done
				fi
			 fi
		   ####################################################################
		   # Log files size monitor - end
		   ####################################################################
		 done # while
		 echo "END - $(date +%Y%m%dh%H%M%S)" >> $logname
	;;
esac

echo "main script finished on "$(date +%Y%m%dh%H%M%S) >> $lognameMain
echo "##############################################" >> $lognameMain
tar -zcvf $pathFld.tgz $pathFld
sleep 1
#subjMail=$pathFld" session logs - IP address "$nodeIp
#echo "Script finished - here in attach the logs" | mailx -s "$subjMail" -a $pathFld.tgz @ericsson.com
exit 0
