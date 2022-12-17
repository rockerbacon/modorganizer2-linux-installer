#!/usr/bin/env bash

screen_text=$( \
cat << EOF
Before continuing, we need to do a few things:

1. Make sure the game has no launch options set
	1.1. On Steam: right click the game > Properties > General > Launch Options

2. Make sure the game is configured to use Proton 6.3
	2.1. On Steam: right click the game > Properties > Compatibility
	2.2. Check the option "Force the use of a specific Steam Play compatibility tool"
	2.3. Select Proton 6.3 in the dropdown

3. Make sure the game ran at least once after selecting Proton 6.3

4. Make sure the game is not running right now
EOF
)

confirmation=$( \
	"$dialog" \
		radio \
		200 "$screen_text" \
		"0" "Cancel the installation" \
		"1" "All done. Let's continue" \
)

if [ "$confirmation" == "0" ]; then
	log_error "installation cancelled by the user"
	exit 1
fi

