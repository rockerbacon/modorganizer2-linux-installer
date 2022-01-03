#!/bin/bash

appid=$1; shift

if [ -n "$STEAM_LIBRARY" ]; then
	echo "$STEAM_LIBRARY/steamapps/compatdata/$appid"
	exit 0
fi

function log_info() {
	echo "INFO: $1" >&2
}

steam_dir=$(readlink -f "$HOME/.steam/root")

steam_install_candidates=( \
	"$steam_dir" \
	"$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam" \
)
for steam_install in "${steam_install_candidates[@]}"; do
	if [ -d "$steam_install" ]; then
		log_info "found Steam in '$steam_install'"

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
		log_info "steam not found in '$steam_install'"
	fi
done

for libdir in "${steam_libraries[@]}"; do
	compat_data="$libdir/steamapps/compatdata/$appid"
	if [ -d "$compat_data" ]; then
		log_info "game found in '$libdir'"
		echo "$libdir"
		exit 0
	else
		log_info "game not found in '$libdir'"
	fi
done

