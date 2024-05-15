#!/usr/bin/env bash

###    PARSE POSITIONAL ARGS    ###
nxm_link=$1; shift

if [ -z "$nxm_link" ]; then
	echo "ERROR: please specify a NXM Link to download"
	exit 1
fi

if [ -n "$(command -v zenity)" ]; then
	ui_bin="zenity"
elif [ -z "$(command -v kdialog)" ]; then
	ui_bin="kdialog"
else
    echo "Error zenity or kdialog required, install one" >&2
	exit 1
fi

nexus_game_id=${nxm_link#nxm://}
nexus_game_id=${nexus_game_id%%/*}
###    PARSE POSITIONAL ARGS    ###

instance_link="$HOME/.config/modorganizer2/instances/${nexus_game_id:?}"
instance_dir=$(readlink -f  "$instance_link")
if [ ! -d "$instance_dir" ]; then
	[ -L "$instance_link"] && rm "$instance_link"

	error_text="Could not download file because there is no Mod Organizer 2 instance for '$nexus_game_id'"
	case "$ui_bin" in
	zenity)
		zenity --ok-label=Exit --error --text "$error_text"
	;;
	kdialog)
	    kdialog --ok-label=Exit --error "$error_text"
	;;
	esac
		
	exit 1
fi

instance_dir_windowspath="Z:$(sed 's/\//\\\\/g' <<<$instance_dir)"
pgrep -f "$instance_dir_windowspath\\\\modorganizer2\\\\ModOrganizer.exe"
process_search_status=$?

game_appid=$(cat "$instance_dir/appid.txt")

if [ "$process_search_status" == "0" ]; then
	echo "INFO: sending download '$nxm_link' to running Mod Organizer 2 instance"
	download_start_output=$(WINEESYNC=1 WINEFSYNC=1 protontricks-launch --appid "$game_appid" "$instance_dir/modorganizer2/nxmhandler.exe" "$nxm_link")
	download_start_status=$?
else
	echo "INFO: starting Mod Organizer 2 to download '$nxm_link'"
	download_start_output=$(steam -applaunch "$game_appid" "$nxm_link")
	download_start_status=$?
fi

if [ "$download_start_status" != "0" ]; then
	error_text="Failed to start download:\n\n$download_start_output"
	case "$ui_bin" in
	zenity)
		zenity --ok-label=Exit --error --text "$error_text"
	;;
	kdialog)
	    kdialog --ok-label=Exit --error "$error_text"
	;;
	esac
	exit 1
fi

