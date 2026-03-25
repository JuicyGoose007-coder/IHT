#!/usr/bin/env bash

STYLE="$HOME/.config/rofi/launcher.rasi"

rofi -show drun \
    -theme "$STYLE" \
    -kb-move-char-back    "" \
    -kb-move-char-forward "" \
    -kb-row-up    "Alt+k,Up" \
    -kb-row-down  "Alt+j,Down" \
    -kb-row-left  "Alt+h,Left" \
    -kb-row-right "Alt+l,Right" \
    -kb-clear-line "Alt+c,slash"
