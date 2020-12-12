#!/bin/bash

WINEPREFIX="$game_prefix" \
"$HOME/.local/share/lutris/runtime/winetricks/winetricks" -q $mo2_tricks $game_tricks

if [ "$?" != "0" ]; then
		"$CACHE/utils/dialog.sh" errorbox \
				"Error while installing winetricks, please run Lutris from a terminal and check the logs"
		exit 1
fi

