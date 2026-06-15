#!/bin/bash

declare -A icons=(
    ["performance"]=$''
    ["balanced"]=$''
    ["power-saver"]=$''
)

if [[ "$1" == "cycle" ]]; then
    profiles=(performance balanced power-saver)
    current=$(powerprofilesctl get)
    for i in "${!profiles[@]}"; do
        if [[ "${profiles[$i]}" == "$current" ]]; then
            next="${profiles[$(( (i + 1) % ${#profiles[@]} ))]}"
            powerprofilesctl set "$next"
            exit 0
        fi
    done
fi

profile=$(powerprofilesctl get)
icon=${icons[$profile]:-$''}

echo "{\"text\": \"$icon   $profile\", \"tooltip\": \"Power profile: $profile\"}"
