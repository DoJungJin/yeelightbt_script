#!/bin/bash

# set your yeelight bt mac address
export YEELIGHTBT_MAC=F8:24:41:E0:92:12

# atomic operation function
function runstate() {
	mkdir /config/yeelight.run
	while [[ "$?" -gt 0 ]]
	do
		echo "lock fail!!! retrying..."
		sleep 1
		mkdir /config/yeelight.run
	done
}

# command send function
# for brightness / temperature / color
function sendcommand() {
	temp_value=1

	# for failsafe sendcommand()
	while [ "$temp_value" != "0" ]
	do
		echo "yeelight setting..."
	    sleep 1

		# for color settings.
		# convert white value <---> rgb(24bit)
		if [ "$1" = "color" ]; then
			color_value="0x$2"
			color_red=$((($color_value & 0xFF0000) >> 16))
			color_green=$((($color_value & 0x00FF00) >> 8))
			color_blue=$((($color_value & 0x0000FF)))
			yeelightbt color $color_red $color_green $color_blue
		else
			yeelightbt $1 $2
		fi

		# command fail check
		temp_value="$?"
    done
	
	# for save settings value
	# parsing from yeelightbt has long delay
	case $1 in
		brightness)
			echo "$2" > /config/yeelight.bright
			;;
		temperature)
			echo "$2" > /config/yeelight.temp
			;;
		color)
			echo "$2" > /config/yeelight.color
			;;
		*)
			echo "$1" > /config/yeelight.power
			;;
	esac
	rm -rf /config/yeelight.run
}

# main function
# for state / power / bright / temp / color
case $1 in
	state)
		power=$(cat /config/yeelight.power)
		bright=$(cat /config/yeelight.bright)
		temp=$(cat /config/yeelight.temp)
		color=$(cat /config/yeelight.color)	
		
		# make json format
		echo -e "{\n  \"power\": \"$power\",\n  \"bright\": \"$bright\",\n  \"temp\": \"$temp\",\n \"color\": \"$color\"\n}"
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
		# yeelight ~ 6500K
		runstate
		temp_val=$2
		if [ "$2" -gt 6500 ]; then
			temp_val=6500
		fi
		sendcommand "temperature" "$temp_val"
		;;
	color)
		runstate
		sendcommand "color" "$2"
		;;
	*)
		;;
esac


exit 0
