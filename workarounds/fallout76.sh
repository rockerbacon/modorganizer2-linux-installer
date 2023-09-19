#!/usr/bin/env bash

mo2_plugin_dir="$install_dir/plugins"

# Since Fallout 76 isn't (yet) officially supported, only via third party dll.
# User should use it at their own risk.
confirm_download_plugin=$( \
    "$dialog" \
        dangerquestion \
        "For Fallout 76 to work, Mod Organizer 2 needs a third-party plugin that adds support to the game.\nThe plugin: https://github.com/Holt59/modorganizer-game_fallout76 will download the release version. Do you wish to continue?"
    )

if [ "$confirm_download_plugin" == "1" ]; then
    log_info "undoing installation."
    log_info "purging download cache"
    purge_downloads_cache
    log_info "removing mod organizer 2 install dir"
    rm -rf "$install_dir"
    log_info "removing mod organizer 2 folder in game's folder"
    rm -rf "$game_installation/modorganizer2"
    log_info "removing executable redirect"
    rm "$full_game_executable_path"
    log_info "renaming original's game executable"
    mv "$original_game_executable" "$full_game_executable_path"
    log_info "exiting"
    expect_exit=1
    exit 1
fi

fo76_plugin_url='https://github.com/Holt59/modorganizer-game_fallout76/releases/download/3.0.0-alpha/game_fallout76.dll'

# Since this third party is not compressed, I still follow the same pattern
# from the rest of the script
fo76_plugin="${fo76_plugin_url##*/}"
downloaded_fo76_plugin="$downloads_cache/$fo76_plugin"

if [ ! -f "$downloaded_fo76_plugin" ]; then
    log_info "downloading third party plugin: '$fo76_plugin'"
    "$download" "$fo76_plugin_url" "$downloaded_fo76_plugin"
    log_info "installing third party plugin: copying from '$downloaded_fo76_plugin' to '$mo2_plugin_dir/$fo76_plugin'"
    cp "$downloaded_fo76_plugin" "$mo2_plugin_dir/$fo76_plugin"
fi

