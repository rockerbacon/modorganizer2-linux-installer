#!/bin/bash

appid=$1; shift

steam_dir=$(readlink -f "$HOME/.steam/root")

if [ -n "$STEAM_LIBRARY" ]; then
	echo "$STEAM_LIBRARY/steamapps/compatdata/$appid"
	exit 0
fi

steam_install_candidates=( \
	"$steam_dir" \
	"$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam" \
)
for steam_install in "${steam_install_candidates[@]}"; do
	echo "Searching for Steam in '$steam_install'" >&2
	if [ -d "$steam_install" ]; then
		echo "Found Steam" >&2

		restore_ifs=$IFS
		IFS=$'\n'
			main_library="$steam_install"
			if [ ! -d "$main_library/steamapps" ]; then
				main_library="$steam_install/steam"
			fi

			steam_libraries=("$main_library")
			steam_libraries+=($( \
				grep -oE '/[^"]+' "$main_library/steamapps/libraryfolders.vdf" \
			))
		IFS=$restore_ifs
	else
		echo "Steam not found in this install path" >&2
	fi
done

for libdir in "${steam_libraries[@]}"; do
	echo "Searching for game in library '$libdir'" >&2
	compat_data="$libdir/steamapps/compatdata/$appid"
	if [ -d "$compat_data" ]; then
		echo "Found game" >&2
		echo "$libdir"
		exit 0
	fi
done

echo "ERROR: could not find game with APPID '$appid'" >&2
exit 1

