#!/bin/bash

appid=$1; shift

steam_dir=$(readlink -f "$HOME/.steam/root")

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

        for libdir in "${steam_libraries[@]}"; do
            echo "Searching for game in library '$libdir'" >&2
            if [ -d "$libdir/steamapps/compatdata/$appid" ]; then
                echo "Found game" >&2
                break
            fi
        done

        if [ ! -d "$libdir/steamapps/compatdata/$appid" ]; then
            echo "ERROR: could not find game with APPID '$appid'" >&2
            continue
        fi

        # we found the game, so we print the libdir and exit
        echo "$libdir"
        exit 0
	fi
done

if [ ! -d "$steam_install" ]; then
	msg="could not find Steam"
	echo "ERROR: $msg" >&2
	exit 1
fi

# If we reach this point, we couldnt find the game
exit 1
