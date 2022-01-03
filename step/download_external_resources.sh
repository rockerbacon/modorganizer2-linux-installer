#!/bin/bash

download="$utils/download.sh"

jdk_url='https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jre_x64_windows_8u252b09.zip'

mo2_url='https://github.com/ModOrganizer2/modorganizer/releases/download/v2.2.2.1/Mod.Organizer-2.2.2.1.7z'

downloaded_jdk="$downloads_cache/${jdk_url##*/}"
downloaded_mo2="$downloads_cache/${mo2_url##*/}"

if [ -n "$game_scriptextender_url" ]; then
	downloaded_scriptextender="$downloads_cache/${nexus_game_id}_${game_scriptextender_url##*/}"
fi

function purge_cache() {
	if [ -f "$downloaded_scriptextender" ]; then
		log_info "removing '$downloaded_scriptextender'"
		rm "$downloaded_scriptextender"
	fi

	if [ -f "$downloaded_mo2" ]; then
		log_info "removing '$downloaded_mo2'"
		rm "$downloaded_mo2"
	fi

	if [ -f "$downloaded_jdk" ]; then
		log_info "removing '$downloaded_jdk'"
		rm "$downloaded_jdk"
	fi
}

if [ "$cache_enabled" == "0" ]; then
	purge_cache
fi

started_download_step=1

if [ ! -f "$downloaded_jdk" ]; then
	"$download" "$jdk_url" "$downloaded_jdk"
fi

if [ ! -f "$downloaded_mo2" ]; then
	"$download" "$mo2_url" "$downloaded_mo2"
fi

if [ -n "$downloaded_scriptextender" ] && [ ! -f "$downloaded_scriptextender" ]; then
	"$download" "$game_scriptextender_url" "$downloaded_scriptextender"
fi

