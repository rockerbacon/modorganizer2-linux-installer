#!/bin/bash

mo2_tricks="vcrun2019"

tricks="$mo2_tricks $game_protontricks"

log_info "applying winetricks '$tricks'"

WINETRICKS="$downloaded_winetricks" \
PROTON_VERSION="Proton $game_protonver" \
protontricks "$game_appid" -q $tricks \
	| "$dialog" loading "Configuring game prefix\nThis may take a while"

# FIXME this check won't work properly because of the piping above
# the installer entrypoint also sets -e so it shouldn't even be reached
if [ "$?" != "0" ]; then
	# TODO retry, passing option '--force' to winetricks, if issue #61 is detected
	"$dialog" errorbox \
		"Error while installing winetricks, check the terminal for more details"
	exit 1
fi

