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

if [ -n "$(command -v zenity)" ]; then
	ui_bin="zenity"
elif [ -z "$(command -v kdialog)" ]; then
	ui_bin="kdialog"
else
    echo "Error zenity or kdialog required, install one" >&2
	exit 1
fi

display_extract_progress() {
	case "$ui_bin" in
	zenity)
		zenity --progress --auto-kill --auto-close --text="$1" <&0
		;;
	kdialog)
		IFS=" " read -r -a bus_ref <<< "$(kdialog --progressbar "$1")"
		while read -u 5 input; do
			echo "$input" > /dev/tty
			if [[ "$input" =~ ^[0-9]+ ]]; then
				qdbus "${bus_ref[@]}" Set "" value "$input"
				if [ "$input" -ge 100 ]; then
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
	| display_extract_progress "$progress_text"

if [ "$?" != "0" ]; then
	cleanup
	exit 1
fi

