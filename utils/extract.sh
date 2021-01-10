#!/usr/bin/env bash

# usage: extract.sh filename destination
#   destination - directory to extract to. Will be created if non-existent. Leaving empty
#     will result in extraction to the current working directory.

# Requires:
#   - tar and gzip
#   - zip
#   - 7z

echoerr() {
	echo "extract.sh:" "$@" >&2
}


# Preliminary checks
if ! [ -f "$1" ]; then
	echoerr "'$1' does not exist, aborting"
	exit 1
fi

extension="${1#*.}"

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
		echoerr "cannot extract '$1' - unsupported archive type"
		exit 1
		;;
esac

for cmd in "${cmds_needed[@]}"; do
	if ! command -v "$cmd" >& /dev/null; then
		echoerr "command '$cmd' not found but is required for file '$1', aborting"
		exit 1
	fi
done


# Now we can begin the extraction
extractdir="$2"
if [ -d "$extractdir" ]; then
	echoerr "'$extractdir' already exists, aborting"
	exit 1
fi

# Create dir ready for extraction
mkdir -p "$extractdir"


# Quick function to leave things as they were found in case we mess up
cleanup() {
	echoerr "could not extract $1"
	rm -rf "$2"
}


echo "extract.sh: extracting '$1' to '$extractdir'"

case "$extension" in
	"zip")
		if ! unzip "$1" -d "$extractdir" 1> /dev/null; then
			cleanup "$1" "$extractdir"
			exit 1
		fi
		;;
	"tar.gz")
		if ! tar -xvzf "$1" --directory "$extractdir" 1> /dev/null; then
			cleanup "$1" "$extractdir"
			exit 1
		fi
		;;
	"7z")
		if ! 7z x -o"$extractdir" "$1" 1> /dev/null; then
			cleanup "$1" "$extractdir"
			exit 1
		fi
		;;
esac

