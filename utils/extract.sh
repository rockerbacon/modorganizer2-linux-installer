#!/usr/bin/env bash

# usage: extract.sh filename destination
#   destination - directory to extract to. Will be created if non-existent. Leaving empty
#     will result in extraction to the current working directory.

# Requires:
#   - tar and gzip
#   - zip
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

extension="${compressed_file##*.}"

case "$extension" in
	"zip")
		cmds_needed=( "unzip" )
		;;
	"tar.gz")
		cmds_needed=( "tar" "gzip" )
		;;
	"7z")
		cmds_needed=( "7z" )
		;;
	*)
		log_error "cannot extract '$compressed_file' - unsupported archive type"
		exit 1
		;;
esac

for cmd in "${cmds_needed[@]}"; do
	if ! command -v "$cmd" >& /dev/null; then
		log_error "command '$cmd' not found but is required for file '$compressed_file', aborting"
		exit 1
	fi
done


# Create dir ready for extraction
mkdir -p "$destination_dir"

# Quick function to leave things as they were found in case we mess up
cleanup() {
	log_error "could not extract '$compressed_file'"
	rm -rf "$destination_dir"
}

progress_text="Extracting '${compressed_file##*/}'"

echo "INFO: extracting '$compressed_file' to '$destination_dir'"

case "$extension" in
	"zip")
		if ! unzip "$compressed_file" -d "$destination_dir" 1> /dev/null; then
			cleanup
			exit 1
		fi
		;;
	"tar.gz")
		if ! tar -xvzf "$compressed_file" --directory "$destination_dir" 1> /dev/null; then
			cleanup
			exit 1
		fi
		;;
	"7z")
		7z x -o"$destination_dir" "$compressed_file" -bsp1 -bso0 \
			| stdbuf -o128 tr -d '\b' \
			| stdbuf -oL tr -s ' ' '\n' \
			| grep --line-buffered --color=never -oE '[0-9]+%' \
			| zenity --progress --auto-kill --auto-close --text="$progress_text"

		if [ "$?" != "0" ]; then
			cleanup
			exit 1
		fi
		;;
esac

