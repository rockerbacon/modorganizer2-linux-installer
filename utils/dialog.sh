#!/usr/bin/env bash

dialogtype=$1; shift

if [ -z "$(command -v zenity)" ] && [ -z "$(command -v kdialog)" ] ; then
	echo "ERROR: no interface available, make sure zenity is installed on your system" >&2
	exit 1
elif [ -n "$(command -v zenity)" ]; then
	ui_bin="zenity"
elif [ -n "$(command -v kdialog)" ]; then
	ui_bin="kdialog"
fi

debug(){
	[[ -n "$DEBUG" ]] && echo "$@" >&2
}

errorbox() {
	debug "error box: $ui_bin, $1"
	# display an error with an exit button
	case $ui_bin in
	zenity)
		zenity --ok-label=Exit --error --text "$1"
	;;
	kdialog)
		kdialog --ok-label=Exit --error "$1"
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac
	return 0 
}

infobox() {
	# Display info with a continue button
	case $ui_bin in
	zenity)
		zenity --ok-label=Continue --info --text "$1"
	;;
	kdialog)
		kdialog --ok-label=Contnue --msgbox "$1"
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac
	return 0
}

warnbox() {
	# display a warning with a Continue button
	case $ui_bin in
	zenity)
		zenity --ok-label=Continue --warning --text "$1"
	;;
	kdialog)
		kdialog --warningcontinuecancel "$1"
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac
	return 0
}

question() {
	# get yes = 0 or no = 1 from user
	debug "question: $ui_bin, $1"
	case $ui_bin in
	zenity)
		zenity --question --text="$1" >/dev/null
		answer="$?"
	;;
	kdialog)
		kdialog --yesno "$1"
		answer="$?"
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac
	echo "$answer"
	return 0
}

dangerquestion() {
	# get yes = 0 or no = 1 from user, while displaying a warning
	case $ui_bin in
	zenity)
		zenity --extra-button=No --ok-label=Yes --warning --text="$1" >/dev/null
	;;
	kdialog)
		kdialog --warningyesno "$1"
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac
	echo "$?"
	return 0
}

directorypicker() {
	# enter a path or select a directory
	local message=$1; shift
	local default_directory=$1; shift

	local finish_selection="false"
	local selection_entry="$default_directory"
	while [ "$finish_selection" != "true" ]; do
		case $ui_bin in
		zenity)
			raw_entry=$(zenity --entry --entry-text="$selection_entry" --extra-button="Browse" --text "$message");
			confirm=$?
		;;
		kdialog)
			# no extra button in kdialog, using cancel label and second dialog
			raw_entry=$(kdialog --inputbox "$message" "$selection_entry" --cancel-label "Browse or Cancel" );
			confirm=$?
			if [ "$confirm" -eq 1 ]; then
				kdialog --yesno "Browse or cancel?" --yes-label "Browse" --no-label "cancel" \
					&& raw_entry="Browse"
			fi
		;;
		*)
			echo "ERROR: $ui_bin not supported" >&2
			return 1
		;;
		esac
		
		eval selection_entry="$raw_entry"

		case "$confirm" in
		0)
			if [ ! -e "$selection_entry" ]; then
				local confirm_create_dir=$( \
					question \
					"Directory '$selection_entry' does not exist. Would you like to create it?" \
				)

				if [ "$confirm_create_dir" == "0" ]; then
					mkdir -p "$selection_entry"
					finish_selection=true
				fi
			elif [ -n "$(ls -A "$selection_entry/")" ]; then
				local confirm_overwrite=$( \
					dangerquestion \
					"Directory '$selection_entry' is not empty. Would you like to continue anyway?" \
				)

				if [ "$confirm_overwrite" == "0" ]; then
					finish_selection=true
				fi
			else
				finish_selection=true
			fi
		;;
		1)
			if [ "$selection_entry" == "Browse" ]; then
				case $ui_bin in
					zenity)
						selection_entry=$(zenity --file-selection --directory)
						;;
					kdialog)
						selection_entry=$(kdialog --getexistingdirectory)
						;;
					*)
						;;
				esac
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
	# enter some text and return it
	message=$1; shift
	default_value=$1; shift

	case $ui_bin in
	zenity)
		entry_value=$(zenity --entry --entry-text="$default_value" --text "$message"); 
		confirm=$?
	;;
	kdialog)
		entry_value=$(kdialog --inputbox "$message" "$default_value");
		confirm=$?
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac

	if [ "$confirm" == "0" ]; then
		echo "$entry_value"
	fi

	return "$confirm"
}

radio() {
	debug "radio: $radio"
	# debug "$(echo "$@" | tr ' ' '\n')"
	# allow user to select one of a few options
	height=$1
	title=$2
	shift 2

	local rows=()
	while [ "$#" -gt "0" ]; do
		debug "new row: $1 $2"
		case $ui_bin in
		zenity)
			rows+=('' "$1" "$2")
			;;
		kdialog)
			rows+=("$1" "$2" "off")
			
		;;
		*)
			echo "ERROR: $ui_bin not supported" >&2
			return 1
		;;
		esac
		shift 2
	done

	case $ui_bin in
	zenity)
		selected_option=$( \
			zenity --height="$height" --list --radiolist \
			--text="$title" \
			--hide-header \
			--column="checkbox" --column="option_value" --column="option_text" \
			--hide-column=2 \
			"${rows[@]}" \
		)
	;;
	kdialog)
		tmpstderr="$(mktemp)"
					# --geometry "x${height}" \

		selected_option=$( \
			kdialog --radiolist "$title" \
			"${rows[@]}" \
			2> "$tmpstderr" \
		)
		if grep -q -e "error: Bad file descriptor" "$tmpstderr"; then
			debug "bfd: |$title|\n\n|$height|\n\n|${rows[@]}|"
		fi
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac
	

	if [ -z "$selected_option" ]; then
		# debug "Cancelled at $title\n\n$height\n\n${rows[@]}"
		return 1
	fi

	echo "$selected_option"

	return 0
}

loading() {
	# display loading bar
	case $ui_bin in
	zenity)
		tee /dev/tty <&0 \
			| zenity --progress --auto-close --pulsate --no-cancel --text "$1"
	;;
	kdialog)
		IFS=" " read -r -a bus_ref <<< "$(kdialog --progressbar "$1")"
		while read -u 5 input; do
			echo "$input" > /dev/tty
			if [[ "$input" =~ ^[0-9]+ ]]; then
				num=$(echo $input | tr -d '%' )
				qdbus "${bus_ref[@]}" Set "" value "$num"
				if [ "$num" -ge 100 ]; then
					qdbus "${bus_ref[@]}" close
				fi
			elif [[ "$input" =~ ^\#.* ]]; then
				# new text to use for progress bar
				new_text=$(echo "$input" | tr -d '#' | xargs)
				qdbus "${bus_ref[@]}" setLabelText "$new_text"
			fi
		done 5<&0
		qdbus "${bus_ref[@]}" close
	;;
	*)
		echo "ERROR: $ui_bin not supported" >&2
		return 1
	;;
	esac

	return 0
}

$dialogtype "$@"
exit $?

