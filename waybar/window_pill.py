#!/usr/bin/env python3
import sys
import json
import subprocess
import html
import re
import time

# Configuration
MAX_TITLE_LEN = 42

def get_niri_windows():
    try:
        output = subprocess.check_output(["niri", "msg", "-j", "windows"], text=True)
        return json.loads(output)
    except Exception:
        return []

def get_niri_focused_window():
    try:
        output = subprocess.check_output(["niri", "msg", "-j", "focused-window"], text=True)
        return json.loads(output)
    except Exception:
        return None

def get_niri_workspaces():
    try:
        output = subprocess.check_output(["niri", "msg", "-j", "workspaces"], text=True)
        return json.loads(output)
    except Exception:
        return []

def print_status():
    window = get_niri_focused_window()

    top_line = "Desktop"
    bottom_line = ""

    if window and window.get("app_id"):
        top_line = window.get("app_id", "Unknown") or "Unknown"
        title = window.get("title", "") or ""

        app_id = (window.get("app_id") or "").lower()

        # Remove Discord/Vesktop unread counter like "(209) "
        if "discord" in app_id or "vesktop" in app_id:
            title = re.sub(r"^\(\d+\)\s*", "", title)
            title = re.sub(r"^Discord\s*\|\s*", "", title)

        if len(title) > MAX_TITLE_LEN:
            title = title[:MAX_TITLE_LEN - 3]

        bottom_line = title
    else:
        workspaces = get_niri_workspaces()
        active = next((ws for ws in workspaces if ws.get("is_focused")), None)
        ws_id = active.get("idx", 1) if active else 1
        top_line = f"Workspace {ws_id}"

    top_line = html.escape(top_line)
    bottom_line = html.escape(bottom_line)

    text = (
        f"<span size='small' foreground='#a6adc8' rise='-1000'>{top_line}</span> "
        f"<span size='8500' weight='bold' foreground='#ffffff'>{bottom_line}</span>"
    )

    print(json.dumps({
        "text": text,
        "class": "custom-window",
        "tooltip": f"{top_line}: {bottom_line}"
    }), flush=True)

# Initial run
print_status()

# Poll for updates (niri doesn't have a socket event stream like Hyprland)
try:
    proc = subprocess.Popen(
        ["niri", "msg", "event-stream"],
        stdout=subprocess.PIPE, text=True
    )
    for line in proc.stdout:
        if "window" in line.lower() or "workspace" in line.lower():
            print_status()
except Exception:
    # Fallback: poll every second
    while True:
        time.sleep(1)
        print_status()
