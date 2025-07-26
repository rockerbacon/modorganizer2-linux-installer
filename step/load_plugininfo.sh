#!/usr/bin/env bash

if [ -z "${selected_plugins:-}" ]; then
	plugin_names=("")
	plugin_download_urls=("")
	plugin_download_files=("")
	return 0
fi

IFS='|' read -ra plugins <<< "${selected_plugins}"

load_gameinfo=()
for plugin in "${plugins[@]}"; do
	load_gameinfo+=("$pluginsinfo/$plugin.sh")
done

names=()
urls=()
filelists=()

for plugin in "${load_gameinfo[@]}"; do
	plugin_data=$(bash -c "
		source \"$plugin\"
		echo \"name=\$plugin_name\"
		echo \"url=\$plugin_download_url\"
		if [ \"\${plugin_download_files}\" = \"*\" ]; then
			echo \"files=*\"
		elif declare -p plugin_download_files 2>/dev/null | grep -q 'declare -a'; then
			echo \"files=\$(IFS='|'; echo \${plugin_download_files[*]})\"
		else
			echo \"files=\$plugin_download_files\"
		fi
	")

	name=""
	url=""
	files=""
	while IFS='=' read -r key value; do
		case "$key" in
			name) name="$value" ;;
			url) url="$value" ;;
			files) files="$value" ;;
		esac
	done <<< "$plugin_data"

	if [ -z "$url" ]; then
		log_error "empty plugin_download_url for '$(basename "$plugin" .sh)'"
		exit 1
	fi

	names+=("$name")
	urls+=("$url")
	filelists+=("$files")
done

plugin_names=("${names[@]}")
plugin_download_urls=("${urls[@]}")
plugin_download_files=("${filelists[@]}")
