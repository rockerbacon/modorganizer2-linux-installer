#!/usr/bin/env bash

# usage: download.sh url
#   downloads resource at  url  to the current working directory.

echoerr() {
	echo "download.sh:" "$@" >&2
}


url="$1"

if [ "$url" == "" ]; then
	echoerr "must specify source url"
	exit 1
fi


# We default to wget because it seems like a better choice for this sort of work -
# doesn't overwrite files by default, better progress bar, downloads resources that
# don't have a name e.g. https://example.com/.
if command -v wget >& /dev/null; then
	use="wget"
elif command -v curl >& /dev/null; then
	use="curl"
else
	echoerr "either wget or curl must be installed on this system"
	exit 1
fi


echo "download.sh: fetching remote resource at '$1'"

case "$use" in
	"wget")
		if ! wget "$url" --progress=bar --no-verbose --show-progress; then
			echoerr "could not fetch '$url'"
			exit 1
		fi
		;;
	"curl")
		if ! curl "$url" -O -# 1> /dev/null; then
			echoerr "could not fetch '$url'"
			exit 1
		fi
		;;
esac

