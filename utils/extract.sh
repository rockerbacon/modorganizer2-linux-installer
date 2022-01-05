#!/usr/bin/env bash

# usage: extract.sh filename destination
#   destination - directory to extract to. Will be created if non-existent

# Requires:
#   - 7z

log_error() {
	echo "ERROR:" "$@" >&2
}

compressed_file=$1
destination_dir=$2

# Preliminary checks
if ! [ -f "$compressed_file" ]; then
	log_error "'$compressed_file' does not exist, aborting"
	exit 1
fi

if [ -n "$(ls -A "$destination_dir/")" ]; then
	log_error "'$destination_dir' is a non-empty directory, aborting"
	exit 1
fi

base_filename=$(basename "$compressed_file")
extension="${base_filename##*.}"

case "$extension" in
	7z|zip)
		;;
	*)
		log_error "cannot extract '$compressed_file' - unsupported archive type '$extension'"
		exit 1
		;;
esac

if ! command -v 7z >& /dev/null; then
	log_error "7z required for extracting files, make sure it is installed"
	exit 1
fi

# Create dir ready for extraction
mkdir -p "$destination_dir"

# Quick function to leave things as they were found in case we mess up
cleanup() {
	log_error "could not extract '$compressed_file'"
	rm -rf "$destination_dir"
}

progress_text="Extracting '${compressed_file##*/}'"

echo "INFO: extracting '$compressed_file' to '$destination_dir'"

7z x -bsp1 -bso0 -o"$destination_dir" "$compressed_file" \
	| stdbuf -o128 tr -d '\b' \
	| stdbuf -oL tr -s ' ' '\n' \
	| grep --line-buffered --color=never -oE '[0-9]+%' \
	| zenity --progress --auto-kill --auto-close --text="$progress_text"

if [ "$?" != "0" ]; then
	cleanup
	exit 1
fi

