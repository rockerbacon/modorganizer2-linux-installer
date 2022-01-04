#!/bin/bash

function install_files() {
	if [ -d "$extracted_jdk" ]; then
		jdk_installation="$game_prefix/drive_c/java"

		if [ -d "$jdk_installation" ]; then
			log_info "removing existing JDK installation in '$jdk_installation'"
			rm -rf "$jdk_installation/*"
		else
			mkdir "$jdk_installation"
		fi

		log_info "installing JDK in '$jdk_installation'"
		cp -R --no-preserve=mode,ownership "$extracted_jdk"/* "$jdk_installation"
	fi

	if [ -d "$extracted_mo2" ]; then
		mo2_installation="$install_dir/modorganizer2"
		if [ -d "$mo2_installation" ]; then
			# TODO give user the option to overwrite files in existing installation
			log_info "Mod Organizer 2 already installed, skipping"
		else
			log_info "installing Mod Organizer 2 in '$mo2_installation'"
			mkdir "$mo2_installation"
			cp -a "$extracted_mo2/." "$mo2_installation"
		fi
	fi

	if [ -d "$extracted_scriptextender" ]; then
		log_info "installing script extender in '$game_installation'"

		for scriptextender_file in "${game_scriptextender_files[@]}"; do
			scriptextender_filepath="$extracted_scriptextender/$scriptextender_file"
			log_info "copying '$scriptextender_filepath' into '$game_installation'"
			cp -af "$scriptextender_filepath" "$game_installation"
		done
	fi
}

install_files | \
	"$dialog" loading "Installing necessary files\nThis shouldn't take long"

