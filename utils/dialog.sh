#!/bin/bash

dialogtype=$1; shift

if [ -z "$(command -v zenity)" ]; then
	echo "ERROR: no interface available. Make sure zenity or xmessage or xterm are installed on the system"
	exit 1
fi

errorbox() {
	zenity --ok-label=Exit --ellipsize --error --text "$1"
	return 1
}

infobox() {
	zenity --ok-label=Continue --ellipsize --info --text "$1"
	return 0
}

warnbox() {
	zenity --ok-label=Continue --ellipsize --warning --text "$1"
	return 0
}

directorypicker() {
	message=$1; shift

	finish_selection="false"
	selection_entry=""
	while [ "$finish_selection" != "true" ]; do
		raw_entry=$(zenity --entry --entry-text="$selection_entry" --extra-button="Browse" --text "$message"); confirm=$?
		eval selection_entry="$raw_entry"

		case "$confirm" in
			0)
				if [ ! -d "$selection_entry" ]; then
					zenity --error --ellipsize --text="Directory '$selection_entry' does not exist"
				else
					finish_selection=true
				fi
				;;
			1)
				if [ "$selection_entry" == "Browse" ]; then
					selection_entry=$(zenity --file-selection --directory)
				else
					finish_selection=true
				fi
				;;
		esac
	done

	if [ "$confirm" == "0" ]; then
		echo $(realpath "$selection_entry")
	fi

	return $confirm
}

textentry() {
	message=$1; shift
	default_value=$1; shift

	entry_value=$(zenity --entry --entry-text="$default_value" --text "$message"); confirm=$?

	if [ "$confirm" == "0" ]; then
		echo "$entry_value"
	fi

	return $confirm
}

radio() {
	title=$1; shift
	selected_option=$(zenity --list --radiolist --column="option_value" --column="option_text" --hide-header --text="$title" "$@")

	if [ -z "$selected_option" ]; then
		return 1
	fi

	echo "$selected_option"

	return 0
}

$dialogtype "$@"
exit $?

