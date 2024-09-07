#!/bin/bash
CDROM=/dev/sr1
ROBOT=/dev/ttyUSB0
command_robot () {
  echo  "Command $1 $2"
  RESULT=$(robotio.py $1)
  echo " result: $RESULT"
}

reset_robot () {
  echo -n "Reset robot"
  command_robot "C00"
}

rip_disc () {
	date						#Show date/time
	reset_robot
	command_robot S00	"Get status"	 	#Get robot status
	# Get next disc
	command_robot "I00" "Get disc"			#Get disc in robot
	if [[ "$RESULT" == "E" ]]; then
	  command_robot "C00" "Reset robot arm"
	  exit 1
	fi 
	sleep 2
	echo "Open tray"
	eject $CDROM
	sleep 3 								#Wait 3 seconds for tray to open
	command_robot "R00"	"Drop disc in tray"	#Drop disc into tray
	eject -t $CDROM							#Close tray
	sleep 30								#Wait for disc to read
	abcde									#Rip disc
	echo "Ripping finished"
	eject $CDROM							#Eject disc tray
	sleep 3									#Wait for tray to open
	command_robot "G00" "Get disc from tray"
	echo "Close tray"
	eject -t $CDROM							#Close tray
	command_robot "R00" "Drop disc in bin"
}
#Initialize robot
reset_robot									#Reset Robot
command_robot V00 Version					#Get version
while true
do
  rip_disc
done

