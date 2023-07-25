#!/usr/bin/env bash

desired_file=$1

if [ -n "$STEAM_LIBRARY" ]; then
	echo "$STEAM_LIBRARY"
	exit 0
fi

function log_info() {
	echo "INFO:" "$@" >&2
}

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

"$script_root/list-steam-libraries.sh" | \
while read -r libdir; do
	full_path="$libdir/steamapps/common/$desired_file"
	if [ -f "$full_path" ]; then
		log_info "game found in '$libdir'"
		echo "$libdir"
		exit 0
	else
		log_info "game not found in '$libdir'"
	fi
done
