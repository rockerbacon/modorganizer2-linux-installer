#!/usr/bin/env bash

shopt -s nullglob

screen_text=$( \
cat << EOF
Which plugins would you like to install?
EOF
)

array=()
for file in "$pluginsinfo/"*.sh; do
    [ -e "$file" ] || continue
    plugin_id=$(basename "$file" .sh)
    plugin_name=$(grep -m 1 '^plugin_name=' "$file" | sed -E "s/plugin_name=([\"']?)(.*)\1/\2/")
    array+=("$plugin_id" "$plugin_name")
done


selected_plugins=$( \
    "$dialog" \
        check \
        350 "$screen_text" \
        "${array[@]}" \
)

if [ -z "$selected_plugins" ]; then
    log_error "no plugins selected"
    exit 1
fi

echo $selected_plugins