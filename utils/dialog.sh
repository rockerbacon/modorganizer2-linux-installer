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

question() {
	zenity --text="$1"
	return $?
}

question() {
	zenity --question --ellipsize --text="$1"
	return $?
}

dangerquestion() {
	zenity --question --ellipsize --icon-name=dialog-warning --text="$1"
	return $?
}

directorypicker() {
	message=$1; shift
	default_directory=$1; shift

	finish_selection="false"
	selection_entry="$default_directory"
	while [ "$finish_selection" != "true" ]; do
		raw_entry=$(zenity --entry --entry-text="$selection_entry" --extra-button="Browse" --text "$message"); confirm=$?
		eval selection_entry="$raw_entry"

		case "$confirm" in
			0)
				if [ ! -e "$selection_entry" ]; then
					question "Directory '$selection_entry' does not exist. Would you like to create it?"
					if [ "$?" == "0" ]; then
						mkdir -p "$selection_entry"
						finish_selection=true
					fi
				elif [ -n "$(ls -A "$selection_entry/")" ]; then
					dangerquestion "Directory '$selection_entry' is not empty. Would you like to continue anyway?"
					if [ "$?" == "0" ]; then
						finish_selection=true
					fi
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
	height=$1
	title=$2
	shift 2

	local rows=()
	while [ "$#" -gt "0" ]; do
		rows+=('' "$1" "$2")
		shift 2
	done

	echo "ROWS: ${rows[@]}" >&2
	selected_option=$( \
		zenity --height="$height" --list --radiolist \
		--text="$title" \
		--hide-header \
		--column="checkbox" --column="option_value" --column="option_text" \
		--hide-column=2 \
		"${rows[@]}" \
	)

	if [ -z "$selected_option" ]; then
		return 1
	fi

	echo "$selected_option"

	return 0
}

$dialogtype "$@"
exit $?

