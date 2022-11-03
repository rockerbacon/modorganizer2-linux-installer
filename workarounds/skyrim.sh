#!/usr/bin/env bash

data="$game_installation/Data"
proc_patchers="$data/SkyProc Patchers"

# some tools need empty directories in the real filesystem to work
# this list probably does not cover all tools
mkdir -p "$proc_patchers/Automatic Variants"
mkdir -p "$proc_patchers/Requiem"
mkdir -p "$data/tools/GenerateFNIS_for_Users"

# enables DXVK "d3d9.evictManagedOnUnlock"
# should allow the game to use more memory without relying on ENBoost
cp "$workarounds/dxvk_memory_patch_enabled.conf" "$game_installation/dxvk.conf"

