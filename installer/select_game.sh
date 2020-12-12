#!/bin/bash

screen_text=$( \
cat << EOF
Welcome to the Mod Organizer 2 installer!

This installer only allows Mod Organizer 2 to manage a single game.
Install one instance of Mod Organizer 2 for each game you want to manage.

Which game would you like to manage with this installation?
EOF
)

# TODO change to a radio or dropbox
nexus_game_id=$( \
	"$dialog" \
		textentry \
		"$screen_text" \
		"skyrim"
)

if [ -z "$nexus_game_id" ]; then
	echo "ERROR: no game selected" >&2
	exit 1
fi

echo "$nexus_game_id"

