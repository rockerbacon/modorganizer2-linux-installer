#!/usr/env/bin bash

appid=$1

if [ -n "$STEAM_LIBRARY" ]; then
	echo "$STEAM_LIBRARY"
	exit 0
fi

function log_info() {
	echo "INFO:" "$@" >&2
}

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

steam_libraries=($("$script_root/list-steam-libraries.sh"))

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

