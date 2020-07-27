#!/bin/bash

export YEELIGHTBT_MAC=F8:24:41:E0:92:12

function runstate() {
	mkdir /config/yeelight.run
	while [[ "$?" -gt 0 ]]
	do
		echo "lock fail!!! retrying..."
		sleep 1
		mkdir /config/yeelight.run
	done
}

function sendcommand() {
	value=$(yeelightbt $1 $2)
	while [ "$?" != "0" ]
	do
		echo "retry yeelight setting..."
	    sleep 1
	    value=$(yeelightbt $1 $2)
    done
	
	case $1 in
		brightness)
			echo "$2" > /config/yeelight.bright
			;;
		temperature)
			echo "$2" > /config/yeelight.temp
			;;
		*)
			echo "$1" > /config/yeelight.power
			;;
	esac
	rm -rf /config/yeelight.run
}

case $1 in
	state)
		power=$(cat /config/yeelight.power)
		bright=$(cat /config/yeelight.bright)
		temp=$(cat /config/yeelight.temp)		

		echo -e "{\n  \"power\": \"$power\",\n  \"bright\": \"$bright\",\n  \"temp\": \"$temp\"\n}"
		;;
	power)
		runstate
		if [ "$2" = "on" ]; then
			sendcommand $2
		elif [ "$2" = "off" ]; then
			sendcommand $2
		fi
		;;
	bright)
		runstate
		sendcommand "brightness" "$2"
		;;
	temp)
		runstate
		temp_val=$2
		if [ "$2" -gt 6500 ]; then
			temp_val=6500
		fi
		sendcommand "temperature" "$temp_val"
		;;
	*)
		;;
esac


exit 0
