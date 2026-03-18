#!/bin/bash

CACHE="/tmp/waybar_weather_cache"
LOCK="/tmp/waybar_weather_lock"

# Show cached value or placeholder while fetching
if [ -f "$CACHE" ]; then
    cat "$CACHE"
else
    echo "Fetching weather..."
fi

# Fetch new data in background if not already fetching
if [ ! -f "$LOCK" ]; then
    touch "$LOCK"
    (
        result=$(curl -s --max-time 10 'https://wttr.in/Nashville?Q&format=3&u' || echo '⚠ Weather Unavailable')
        echo "$result" > "$CACHE"
        rm -f "$LOCK"
    ) &
fi
