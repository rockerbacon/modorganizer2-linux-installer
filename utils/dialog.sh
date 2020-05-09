#!/bin/bash

if [ -n "$FORCE_INTERFACE" ]; then
	interface=$FORCE_INTERFACE
elif [ -n "$(command -v zenity)" ]; then
	interface="zenity"
elif [ -n "$(command -v xmessage)" ]; then
	interface="xmessage"
elif [ -n "$(command -v xterm)" ]; then
	interface="xterm"
else
	echo "ERROR: no interface available. Make sure zenity or xmessage or xterm are installed on the system"
	exit 1
fi

xtermbox() {
	action_on_exit=$1
	msg=$2
	xterm -e bash -c "
		echo '$msg'
		echo
		echo Press enter to $action_on_exit
		read
	"
}

errorbox() {
	message=$1; shift
	case "$interface" in
		zenity)
			zenity --ok-label=Exit --ellipsize --error --text "$message"
			;;
		xmessage)
			xmessage -buttons exit:1 "$message"
			;;
		xterm)
			xterm -e bash -c "
				echo '$message'
				echo
				echo -n 'Press enter to exit. '
				read
			"
			;;
	esac

	return 1
}

infobox() {
	message=$1; shift
	case "$interface" in
		zenity)
			zenity --ok-label=Continue --ellipsize --info --text "$message"
			;;
		xmessage)
			xmessage -buttons continue:0 "$message"
			;;
		xterm)
			xterm -e bash -c "
				echo '$message'
				echo
				echo -n 'Press enter to continue. '
				read
			"
			;;
	esac

	return 0
}

dialogtype=$1; shift

$dialogtype "$@"
exit $?

