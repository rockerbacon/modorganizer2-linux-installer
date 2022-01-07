#!/bin/bash

screen_text=$( \
cat << EOF
Do you play this game through Steam Play (Proton)?

If yes, ensure the following before continuing:
	* The game is configured to use Proton 6.3:
		On Steam: right click the game > Properties > tab "General" > Force the use of a specific Steam Play compatibility tool
	* The game was run at least once on Steam
EOF
)

confirmation=$( \
	"$dialog" \
		radio \
		200 "$screen_text" \
		"0" "No, cancel installation" \
		"1" "Yes, I use Steam Play and everything is setup" \
)

if [ "$confirmation" == "0" ]; then
	log_error "installation cancelled by user"
	exit 1
fi

