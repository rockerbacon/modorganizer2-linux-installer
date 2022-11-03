#!/usr/bin/env bash

if [ -n "${game_protontricks[*]}" ]; then
	log_info "applying protontricks ${game_protontricks[@]}"
	if [ "$using_flatpak_protontricks" == "0" ]; then
		WINETRICKS="$downloaded_winetricks" \
		protontricks "$game_appid" -q "${game_protontricks[@]}" \
			| "$dialog" loading "Configuring game prefix\nThis may take a while"
	else
		flatpak run 'com.github.Matoking.protontricks' \
			"$game_appid" -q "${game_protontricks[@]}" \
				| "$dialog" loading "Configuring game prefix\nThis may take a while"
	fi

	if [ "$?" != "0" ]; then
		"$dialog" errorbox \
			"Error while installing winetricks, check the terminal for more details"
		exit 1
	fi
fi

