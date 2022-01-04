#!/bin/bash

tricks="$mo2_tricks $game_protontricks"

log_info "applying winetricks '$tricks'"

# TODO download latest winetricks version instead of using the lutris provided one
WINEPREFIX="$game_prefix" \
"$HOME/.local/share/lutris/runtime/winetricks/winetricks" -q $tricks

if [ "$?" != "0" ]; then
	# TODO retry, passing option '--force' to winetricks, if issue #61 is detected
	"$dialog" errorbox \
		"Error while installing winetricks, check the terminal for more details"
	exit 1
fi

