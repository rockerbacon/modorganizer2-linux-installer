#!/usr/bin/env bash

mo2_installation="$install_dir/modorganizer2"

function install_mo2() {
	log_info "installing Mod Organizer 2 in '$mo2_installation'"
	mkdir -p "$mo2_installation"
	cp -af "$extracted_mo2/." "$mo2_installation"
}

function check_should_install_mo2() {
	local should_install=0

	if [ -d "$extracted_mo2" ]; then
		if [ -d "$mo2_installation" ]; then
			confirm_update=$( \
				"$dialog" question \
					"Mod Organizer 2 is already installed.\nWould you like to update?" \
			)

			if [ "$confirm_update" == "0" ]; then
				should_install=1
			else
				log_info "skipping Mod Organizer 2 update"
			fi
		else
			should_install=1
		fi
	fi

	echo "$should_install"
	return 0
}

should_install_mo2=$(check_should_install_mo2)

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

	if [ "$should_install_mo2" == "1" ]; then
		install_mo2
	fi

	if [ -d "$extracted_scriptextender" ]; then
		log_info "installing script extender in '$game_installation'"

		if [ "${game_scriptextender_files[*]}" == "*" ]; then
			log_info "copying all files from '$extracted_scriptextender' into '$game_installation'"
			cp -an "$extracted_scriptextender"/* "$game_installation" || true
		else
			for scriptextender_file in "${game_scriptextender_files[@]}"; do
				scriptextender_filepath="$extracted_scriptextender/$scriptextender_file"
				log_info "copying '$scriptextender_filepath' into '$game_installation'"
				cp -an "$scriptextender_filepath" "$game_installation" || true
			done
		fi
	fi
}

install_files \
	| "$dialog" loading "Installing necessary files\nThis shouldn't take long"

