#!/bin/bash

dependencies=( \
	"zenity" \
)

for dependency in "${dependencies[@]}"; do
	if [ -z "$(command -v "$dependency")" ]; then
		log_error "missing dependency '$dependency'"
		"$dialog" \
			errorbox \
			"Installer requires '$dependency' but it is not installed in your system"

		exit 1
	fi
done

log_info "all dependencies met"

