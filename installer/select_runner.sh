#!/bin/bash

screen_text=$( \
cat << EOF
Do you play this game through Steam Play (Proton)?

If yes, ensure the following before continuing:
	* The game is configured to use Proton 5.0:
		On Steam: right click the game > Properties > tab "General" > Force the use of a specific Steam Play compatibility tool
	* The game was run at least once on Steam
EOF
)

# TODO change to a radio
runner=$( \
	"$dialog" \
		radio \
		200 "$screen_text" \
		"" "No, cancel installation" \
		"proton" "Yes, I use Steam Play and everything is setup" \
)

if [ -z "$runner" ]; then
	echo "ERROR: no runner selected"
	exit 1
fi

echo "$runner"

