#!/bin/bash

picker_text=$( \
cat << EOF
Select where you would like to install Mod Organizer 2
EOF
)

# TODO change default directory
directory=$( \
	"$dialog" \
		directorypicker \
		"$picker_text" \
		"$HOME/Games/mod-organizer-2-test" \
)

if [ -z "$directory" ]; then
	echo "ERROR: no install directory selected" >&2
	exit 1
fi

echo "$directory"

