#!/usr/bin/env bash

function log_error() {
	echo "ERROR: $@" >&2
}

function get_release() {
	if [ -z "$(command -v protontricks)" ]; then
		if [ -n "$(command -v flatpak)" ]; then
			if flatpak info com.github.Matoking.protontricks &> /dev/null; then
				echo "flatpak"
				return 0
			fi
		fi
	else
		echo "system"
		return 0
	fi

	return 1
}

function do_protontricks() {
	release=$(get_release)

	case "$release" in
		flatpak)
			WINETRICKS='' \
			flatpak run 'com.github.Matoking.protontricks' "$@"
			return $?
		;;
		system)
			protontricks "$@"
			return $?
		;;
		*)
		log_error "Protontricks unavailable"
		return 1
		;;
	esac
}

function apply() {
	appid=$1; shift
	do_protontricks "$appid" -q "$@"
	return $?
}

function get_prefix() {
	do_protontricks -c 'echo $WINEPREFIX' "$1"
	return $?
}

action=$1
shift

case "$action" in
	get-prefix)
		get_prefix "$1"
	;;
	get-release)
		get_release
	;;
	apply)
		apply "$@"
	;;
	*)
		log_error "invalid action '$action'"
		exit 1
	;;
esac

