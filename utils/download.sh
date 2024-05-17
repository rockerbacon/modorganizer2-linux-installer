#!/usr/bin/env bash

# usage: download.sh URL DST
#   downloads resource at URL to DST

function log_error() {
	echo "ERROR:" "$@" >&2
}

function log_info() {
	echo "INFO:" "$@"
}

url="$1"
out_file="$2"

if [ -z "$url" ]; then
	log_error "must specify source url"
	exit 1
elif [ -z "$out_file" ]; then
	log_error "must specify output file location"
	exit 1
fi

if [ -n "$(command -v zenity)" ]; then
	ui_bin="zenity"
elif [ -n "$(command -v kdialog)" ]; then
	ui_bin="kdialog"
else
    echo "$0: Error zenity or kdialog required, install one" >&2
	exit 1
fi

display_download_progress() {
	case "$ui_bin" in
	zenity)
		zenity --progress --auto-kill --auto-close --text "$1" <&0
	;;
	kdialog)
		IFS=" " read -r -a bus_ref <<< "$(kdialog --progressbar "$1")"
		while read -u 5 input; do
			if [[ "$input" =~ ^[0-9]+ ]]; then
				num=$(echo $input | tr -d '%' )
				qdbus "${bus_ref[@]}" Set "" value "$num"
				if [ "$num" -ge 100 ]; then
					qdbus "${bus_ref[@]}" close
				fi
			elif [[ "$input" =~ ^\#.* ]]; then
				# new text to use for progress bar
				new_text=$(echo "$input" | tr -d '#' | xargs)
				qdbus "${bus_ref[@]}" setLabelText "$new_text"
			fi
		done 5<&0
	;;
	esac
}

progress_bar() {
	stdbuf -o0 tr '[:cntrl:]' '\n' \
		| grep --color=never --line-buffered -oE '[0-9\.]+%' \
		| display_download_progress "$1"
}

# We default to wget because it seems like a better choice for this sort of work -
# doesn't overwrite files by default, better progress bar, downloads resources that
# don't have a name e.g. https://example.com/.
if [ -n "$DOWNLOAD_BACKEND" ]; then
	download_backend="$DOWNLOAD_BACKEND"
elif command -v wget2 >& /dev/null; then
	log_info "using wget2 backend"
	download_backend="wget2"
elif command -v wget >& /dev/null; then
	log_info "using wget backend"
	download_backend="wget"
elif command -v curl >& /dev/null; then
	log_info "using curl backend"
	download_backend="curl"
else
	log_error "either wget or curl must be installed on this system"
	exit 1
fi

log_info "fetching remote resource at '$1'"

progress_text="Downloading '${out_file##*/}'"

log_info "downloading '$url' to '$out_file'"

case "$download_backend" in
	"wget2")
		wget2 "$url" --no-verbose --force-progress -O "$out_file" 2>&1 \
			| progress_bar "$progress_text"
		;;
		
	"wget")
		wget "$url" --progress=dot --no-verbose --show-progress -O "$out_file" 2>&1 \
			| progress_bar "$progress_text"
		;;

	"curl")
		redirected_url=$(curl -ILs -o /dev/null -w '%{url_effective}' "$url")

		curl "$redirected_url" -o "$out_file" -# 2>&1 \
			| progress_bar "$progress_text"
		;;
esac

if [ "$?" != "0" ]; then
	log_error "could not fetch '$url'"
	exit 1
fi

