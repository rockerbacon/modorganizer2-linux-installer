#!/bin/bash

dependencies=( \
	"zenity" \
)

for dependency in "${dependencies[@]}"; do
	if [ -z "$(command -v "$dependency")" ]; then
		"$dialog" \
			errorbox \
			"Installer requires '$dependency' but it is not installed in your system"

		exit 1
	fi
done

echo "INFO: all dependencies met"

