#!/bin/bash

THEME=~/.config/rofi/notification-center.rasi

# Escape pango special chars for -mesg markup
pe() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

while true; do

  # ── Build list ────────────────────────────────────────────────────────────────
  HISTORY=$(dunstctl history)
  COUNT=$(echo "$HISTORY" | jq '.data[0] | length')

  if [ "${COUNT:-0}" -eq 0 ]; then
    printf '  No notifications' | rofi -dmenu \
      -theme "$THEME" \
      -p "  Notifications" \
      -no-custom \
      -format "i"
    exit 0
  fi

  TMPIDS=$(mktemp)
  TMPENTRIES=$(mktemp)
  echo "$HISTORY" | jq -r '.data[0][].id.data' >"$TMPIDS"

  printf '  Clear All\n' >"$TMPENTRIES"
  BOOT_EPOCH=$(date -d "$(uptime -s)" +%s)
  echo "$HISTORY" | jq -r --argjson boot "$BOOT_EPOCH" '
    .data[0][] |
    now as $now |
    ($boot + (.timestamp.data / 1000000)) as $ts |
    (($now - $ts) |
        if   . < 60    then "just now"
        elif . < 3600  then ((. / 60  | floor | tostring) + "m ago")
        elif . < 86400 then ((. / 3600 | floor | tostring) + "h ago")
        else                ((. / 86400 | floor | tostring) + "d ago")
        end) as $time |
    (.body.data |
        if . == "" then ""
        else "  " + (if length > 50 then .[0:50] + "…" else . end)
        end) as $body |
    (if .icon_path.data != "" then .icon_path.data
     else (.appname.data | ascii_downcase)
     end) as $icon |
    "\(.appname.data)  ·  \(.summary.data)\($body)  \($time)\u0000icon\u001f\($icon)"
' >>"$TMPENTRIES"

  INDEX=$(rofi -dmenu \
    -theme "$THEME" \
    -p "  Notifications" \
    -format "i" \
    -show-icons \
    <"$TMPENTRIES")

  RC=$?
  rm -f "$TMPENTRIES"

  if [ $RC -ne 0 ] || [ -z "$INDEX" ] || [ "$INDEX" -lt 0 ] 2>/dev/null; then
    rm -f "$TMPIDS"
    exit 0
  fi

  if [ "$INDEX" -eq 0 ]; then
    dunstctl history-clear
    rm -f "$TMPIDS"
    exit 0
  fi

  # ── Detail view ───────────────────────────────────────────────────────────────
  ID=$(sed -n "${INDEX}p" "$TMPIDS")
  rm -f "$TMPIDS"
  [ -z "$ID" ] && exit 0

  NOTIF=$(dunstctl history | jq --argjson id "$ID" '.data[0][] | select(.id.data == $id)')
  APPNAME=$(echo "$NOTIF" | jq -r '.appname.data')
  SUMMARY=$(echo "$NOTIF" | jq -r '.summary.data')
  BODY_CLEAN=$(echo "$NOTIF" | jq -r '.body.data' | sed 's/<[^>]*>//g')

  MESG=$(printf '<b><span foreground="#e1e2e8">%s</span></b>\n<span foreground="#a2c9fd">%s</span>' \
    "$(pe "$APPNAME")" "$(pe "$SUMMARY")")
  [ -n "$BODY_CLEAN" ] && MESG=$(printf '%s\n\n<span foreground="#c3c6cf">%s</span>' \
    "$MESG" "$(pe "$BODY_CLEAN")")

  DETAIL_SEL=$(printf '  Back\n  Dismiss\n  Copy to clipboard' | rofi -dmenu \
    -theme "$THEME" \
    -theme-str 'window { width: 620px; } mainbox { children: [inputbar, message, listview]; } listview { fixed-height: true; lines: 3; }' \
    -p "  $APPNAME" \
    -mesg "$MESG" \
    -format "s")

  [ $? -ne 0 ] && exit 0

  case "$DETAIL_SEL" in
  "  Back")
    continue
    ;;
  "  Dismiss")
    dunstctl history-pop "$ID"
    continue
    ;;
  "  Copy to clipboard")
    printf '%s\n%s' "$SUMMARY" "$BODY_CLEAN" | wl-copy
    exit 0
    ;;
  *)
    exit 0
    ;;
  esac

done
