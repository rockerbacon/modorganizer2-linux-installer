#!/bin/bash

download="$utils/download.sh"
extract="$utils/extract.sh"

jdk_url='https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jre_x64_windows_8u252b09.zip'

mo2_url='https://github.com/ModOrganizer2/modorganizer/releases/download/v2.2.2.1/Mod.Organizer-2.2.2.1.7z'

downloaded_jdk="$downloads_cache/${jdk_url##*/}"
extracted_jdk="${downloaded_jdk%.*}"

downloaded_mo2="$downloads_cache/${mo2_url##*/}"
extracted_mo2="${downloaded_mo2%.*}"

if [ -n "$game_scriptextender_url" ]; then
	downloaded_scriptextender="$downloads_cache/${nexus_game_id}_${game_scriptextender_url##*/}"
	extracted_scriptextender="${downloaded_scriptextender%.*}"
fi

function purge_downloads_cache() {
	if [ -f "$downloaded_scriptextender" ]; then
		log_info "removing '$downloaded_scriptextender'"
		rm "$downloaded_scriptextender"

		if [ -d "$extracted_scriptextender" ]; then
			log_info "removing '$extracted_scriptextender'"
			rm -rf "$extracted_scriptextender"
		fi
	fi

	if [ -f "$downloaded_mo2" ]; then
		log_info "removing '$downloaded_mo2'"
		rm "$downloaded_mo2"

		if [ -d "$extracted_mo2" ]; then
			log_info "removing '$extracted_mo2'"
			rm -rf "$extracted_mo2"
		fi
	fi

	if [ -f "$downloaded_jdk" ]; then
		log_info "removing '$downloaded_jdk'"
		rm "$downloaded_jdk"

		if [ -d "$extracted_jdk" ]; then
			log_info "removing '$extracted_jdk'"
			rm -rf "$extracted_jdk"
		fi
	fi
}

if [ "$cache_enabled" == "0" ]; then
	purge_downloads_cache
fi

started_download_step=1

if [ ! -f "$downloaded_jdk" ]; then
	"$download" "$jdk_url" "$downloaded_jdk"
	mkdir "$extracted_jdk"
	"$extract" "$downloaded_jdk" "$extracted_jdk"
fi

if [ ! -f "$downloaded_mo2" ]; then
	"$download" "$mo2_url" "$downloaded_mo2"
	mkdir "$extracted_mo2"
	"$extract" "$downloaded_mo2" "$extracted_mo2"
fi

if [ -n "$downloaded_scriptextender" ] && [ ! -f "$downloaded_scriptextender" ]; then
	"$download" "$game_scriptextender_url" "$downloaded_scriptextender"
	mkdir "$extracted_scriptextender"
	"$extract" "$downloaded_scriptextender" "$extracted_scriptextender"

	if [ "$nexus_game_id" == "oblivion" ]; then
		# patch OBSE to not complain about running outside of Steam
		printf '\x90\x90\x90' | dd conv=notrunc of="$extracted_scriptextender/obse_loader.exe" bs=1 seek=$((0x14cb))
	fi
fi

