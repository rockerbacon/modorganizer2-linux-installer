#!/bin/bash

appid=$1; shift

restore_ifs=$IFS
IFS=$'\n'
	steam_libraries=("$HOME/.steam/steam")
	steam_libraries+=($( \
		grep -oE '/[^"]+' "$HOME/.steam/steam/steamapps/libraryfolders.vdf" \
	))
IFS=$restore_ifs

for libdir in "${steam_libraries[@]}"; do
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

