#!/usr/bin/env bash

picker_text=$( \
cat << EOF
Select where you would like to install Mod Organizer 2
EOF
)

directory=$( \
	"$dialog" \
		directorypicker \
		"$picker_text" \
		"$HOME/Games/mod-organizer-2-${game_nexusid}" \
)

if [ -z "$directory" ]; then
	log_error "no install directory selected"
	exit 1
fi

echo "$directory"

