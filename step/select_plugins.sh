#!/usr/bin/env bash

shopt -s nullglob

if ! command -v jq >/dev/null 2>&1; then
    log_info "jq is not installed, skipping plugin selection"
    echo ""
    return 0
fi

screen_text=$( \
cat << EOF
Would you like to automatically install any MO2 plugins?
EOF
)

button=$( 
    "$dialog" \
    question \
    "$screen_text" \
)

if [ "$button" != 0 ]; then
    log_info "user chose not to install plugins"
    echo ""
    return 0
fi

screen_text=$( \
cat << EOF
Which plugins would you like to install?
EOF
)

array=()
while IFS=$'\t' read -r id name; do
    array+=("$id" "$name")
done < <(jq -r '.[] | "\(.Identifier)\t\(.Name)"' "$pluginsinfo")


selected_plugins=$( \
    "$dialog" \
        check \
        450 "$screen_text" \
        "${array[@]}" \
)

if [ -z "$selected_plugins" ]; then
    log_info "no plugins selected"
    echo ""
    return 0
fi

echo $selected_plugins