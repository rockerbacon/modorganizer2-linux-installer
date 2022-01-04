#!/bin/bash

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

steam_dir=$(readlink -f "$HOME/.steam/root")
customver=0

function log_error() {
	echo "ERROR:" "$@" &>2
}

function log_info() {
	echo "INFO:" "$@" &>2
}

###     PARSE ARGS     ###
parsing_args=true
while [ "$parsing_args" == "true" ]; do
	argname=$1
	case "$argname" in
		--custom)
			custom=1; shift 1
			;;

		--)
			parsing_args=false; shift 1
			;;

		-*)
			log_error "unknown option '$argname'"
			exit 1
			;;

		*)
			parsing_args=false
			;;
	esac
done

version=$1

if [ -z "$version" ]; then
	log_error "a proton version must be specified"
	exit 1
fi
###     PARSE ARGS     ###

match_proton() {
	echo $(find "$1" \
			-maxdepth 1 -path "*/$2" \
		|	sort -rV \
		|	head -n 1
	)
}

if [ "$custom" == "1" ]; then
	log_info "searching for '$version' in '$steam_dir/compatibilitytools.d/'"
	proton_dir=$(match_proton "$steam_dir/compatibilitytools.d/" "$version")
else
	steam_libraries=($("$script_root/list-steam-libraries.sh"))

	for libdir in "${steam_libraries[@]}"; do
		log_info "searching for 'Proton $version' in library '$libdir'"
		proton_dir=$(match_proton "$libdir/steamapps/common/" "Proton $version")
		if [ -d "$proton_dir" ]; then
			log_info "found Proton in '$proton_dir'"
			break
		fi
	done
fi

log_info "$proton_dir"
if [ ! -d "$proton_dir" ]; then
	log_error "could not find Proton, check terminal output for details"
	exit 1
fi

echo "$proton_dir"

