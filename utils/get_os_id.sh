#!/usr/bin/env bash

function get_from_os_release() {
	if [ ! -f /etc/os-release ]; then
		return 1
	fi

	os_id=$(bash -c 'source /etc/os-release; echo $ID')
	status=$?

	if [ "$status" != "0" ] || [ -z "$os_id" ]; then
		return 1
	fi

	echo $os_id
}

get_from_os_release || echo "unknown"

