#!/usr/bin/env bash

screen_text=$( \
cat << EOF
Do you want to automatically install the script extender for this game?

If you plan to install the script extender via Mod Organizer 2, select "No". Keep in mind that this requires a plugin like Root Builder.
EOF
)

button=$( \
	"$dialog" \
	question \
	"$screen_text"
)

if [ "$button" == 0 ]; then
	echo true
else
	echo false
fi