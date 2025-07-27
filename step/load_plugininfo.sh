#!/usr/bin/env bash

if [ -z "${selected_plugins:-}" ]; then
	plugin_names=("")
	plugin_download_urls=("")
	plugin_download_files=("")
	return 0
fi

IFS='|' read -ra plugins <<< "${selected_plugins}"

plugin_url=()
for plugin in "${plugins[@]}"; do
	plugin_url+=($(jq -r --arg id "$plugin" '.[] | select(.Identifier == $id) | "\(.Manifest)"' "$pluginsinfo"))
done

for i in "${!plugin_url[@]}"; do
	log_info "Querying metadata for plugin: ${plugins[$i]}"
	query=$(curl -s "${plugin_url[$i]}")

	name=$(echo "$query" | jq -r '.Name')
	latest=$(echo "$query" | jq -r '.Versions | sort | last')
	url=$(echo "$latest" | jq -r '.DownloadUrl')
	files=$(echo "$latest" | jq -r '.PluginPath | join("|")')

	if [ -z "$url" ]; then
		log_error "empty plugin_download_url for '${name}'"
		exit 1
	fi

	names+=("$name")
	urls+=("$url")
	filelists+=("$files")

done

plugin_names=("${names[@]}")
plugin_download_urls=("${urls[@]}")
plugin_download_files=("${filelists[@]}")