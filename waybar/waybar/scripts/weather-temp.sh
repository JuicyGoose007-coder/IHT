#!/bin/bash
# Fetch current temperature for Honea Path, SC using Open-Meteo (no API key needed)
# Coordinates: 34.4946, -82.3915
DATA=$(curl -sf "https://api.open-meteo.com/v1/forecast?latitude=34.4946&longitude=-82.3915&current=temperature_2m,weather_code&temperature_unit=fahrenheit" 2>/dev/null)

if [ -z "$DATA" ]; then
    echo '{"text": " --°F", "tooltip": "Weather unavailable"}'
    exit 0
fi

read -r TEMP CODE <<< "$(echo "$DATA" | jq -r '[.current.temperature_2m, .current.weather_code] | @tsv')"

case $CODE in
    0) COND="Clear sky"; ICON="☀️" ;;
    1|2|3) COND="Partly cloudy"; ICON="⛅" ;;
    45|48) COND="Foggy"; ICON="🌫️" ;;
    51|53|55) COND="Drizzle"; ICON="🌦️" ;;
    61|63|65) COND="Rain"; ICON="🌧️" ;;
    66|67) COND="Freezing rain"; ICON="🌨️" ;;
    71|73|75) COND="Snow"; ICON="❄️" ;;
    77) COND="Snow grains"; ICON="❄️" ;;
    80|81|82) COND="Rain showers"; ICON="🌧️" ;;
    85|86) COND="Snow showers"; ICON="🌨️" ;;
    95|96|99) COND="Thunderstorm"; ICON="⛈️" ;;
    *) COND="Unknown"; ICON="🌡️" ;;
esac

TEMP_INT=$(printf "%.0f" "$TEMP")
echo "{\"text\": \"${ICON} ${TEMP_INT}°F\", \"tooltip\": \"${COND} in Honea Path, SC\nCurrent: ${TEMP}°F\"}"
