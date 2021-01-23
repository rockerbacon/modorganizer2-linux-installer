#!/bin/bash

screen_text=$( \
cat << EOF
Welcome to the Mod Organizer 2 installer!

This installer only allows Mod Organizer 2 to manage a single game.
Install one instance of Mod Organizer 2 for each game you want to manage.

Which game would you like to manage with this installation?
EOF
)

nexus_game_id=$( \
	"$dialog" \
		radio \
		450 "$screen_text" \
		"fallout3" "Fallout 3" \
		"fallout4" "Fallout 4" \
		"newvegas" "Fallout New Vegas" \
		"morrowind" "Morrowind" \
		"oblivion" "Oblivion" \
		"skyrim" "Skyrim" \
		"skyrimspecialedition" "Skyrim Special Edition" \
)

if [ -z "$nexus_game_id" ]; then
	echo "ERROR: no game selected" >&2
	exit 1
fi

echo "$nexus_game_id"

