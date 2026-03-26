#!/bin/bash

BELL=$'\uf0a2'
COUNT=$(dunstctl count 2>/dev/null | awk '/History:/{print $2}')

if [ "${COUNT:-0}" -gt 0 ] 2>/dev/null; then
    printf '{"text": "%s %s", "class": "has-notifications"}\n' "$BELL" "$COUNT"
else
    printf '{"text": "%s"}\n' "$BELL"
fi
