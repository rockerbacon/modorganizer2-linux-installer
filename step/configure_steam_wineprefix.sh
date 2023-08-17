#!/usr/bin/env bash

if [ -n "${game_protontricks[*]}" ]; then
	log_info "applying protontricks ${game_protontricks[@]}"

	"$utils/protontricks.sh" apply "$game_appid" "${game_protontricks[@]}" \
		| "$dialog" loading "Configuring game prefix\nThis may take a while"

	if [ "$?" != "0" ]; then
		"$dialog" errorbox \
			"Error while installing winetricks, check the terminal for more details"
		exit 1
	fi
fi

