#!/bin/bash

picker_text=$( \
cat << EOF
Select where you would like to install Mod Organizer 2
EOF
)

directory=$( \
	"$dialog" \
		directorypicker \
		"$picker_text" \
		"$HOME/Games/mod-organizer-2-${nexus_game_id}" \
)

if [ -z "$directory" ]; then
	echo "ERROR: no install directory selected" >&2
	exit 1
fi

echo "$directory"

