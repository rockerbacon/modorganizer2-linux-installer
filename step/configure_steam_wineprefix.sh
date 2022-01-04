#!/bin/bash

proton_dir=$("$utils/find-proton-dir.sh" "$game_protonver")

mo2_tricks="vcrun2019"

tricks="$mo2_tricks $game_protontricks"

log_info "applying winetricks '$tricks'"

WINEPREFIX="$game_prefix" \
WINE="$proton_dir/dist/bin/wine64" \
"$downloaded_winetricks" -q $tricks \
	| tee /dev/tty \
	| "$dialog" loading "Configuring game prefix\nThis may take a while"

if [ "$?" != "0" ]; then
	# TODO retry, passing option '--force' to winetricks, if issue #61 is detected
	"$dialog" errorbox \
		"Error while installing winetricks, check the terminal for more details"
	exit 1
fi

