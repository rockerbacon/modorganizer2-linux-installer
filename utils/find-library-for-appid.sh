#!/bin/bash

appid=$1; shift

steam_libraries=$( \
	grep -oE '/[^"]+' "$HOME/.steam/steam/steamapps/libraryfolders.vdf" \
)
steam_libraries=$(echo -e "$HOME/.steam/steam\n$steam_libraries")

for libdir in $steam_libraries; do
	echo "Searching for game in library '$libdir'" >&2
	if [ -d "$libdir/steamapps/compatdata/$appid" ]; then
		echo "Found game" >&2
		break
	fi
done

if [ ! -d "$libdir/steamapps/compatdata/$appid" ]; then
	echo "ERROR: could not find game with APPID '$appid'" >&2
	exit 1
fi

echo "$libdir"

