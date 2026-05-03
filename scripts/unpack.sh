#!/bin/bash
##########################################################################
# _____ _   _               _____           _                            #
#|_   _| | | |             |_   _|         | |  DATE:XX/XX/XXXX          #
#  | | | |_| | __ ___   _____| | __ _ _ __ | |_ _ __ _   _ _ __ ___  ___ #
#  | | |  _  |/ _` \ \ / / _ \ |/ _` | '_ \| __| '__| | | | '_ ` _ \/ __|#
# _| |_| | | | (_| |\ V /  __/ | (_| | | | | |_| |  | |_| | | | | | \__ \#
# \___/\_| |_/\__,_| \_/ \___\_/\__,_|_| |_|\__|_|   \__,_|_| |_| |_|___/#
##########################################################################
set -euo pipefail

SRC="${SRC:-$HOME/IHT}"

mkdir -p ~/.config ~/Pictures ~/.config/hypr

cp "$SRC/zshrc" ~/.zshrc

for dir in starship fastfetch ghostty niri swaylock nvim yazi waybar tmux dunst wofi rofi wlogout; do
  cp -rfT "$SRC/$dir" ~/.config/"$dir"
done

cp -f "$SRC/hypr/hyprlock.conf" ~/.config/hypr/hyprlock.conf

cp -rfT "$SRC/wallpapers" ~/Pictures/wallpapers
cp -rfT "$SRC/scripts" ~/scripts
cp -rfT "$SRC/Rust" ~/Rust

sudo cp "$SRC/sddm.conf" /etc/sddm.conf
sudo mkdir -p /usr/share/sddm/themes
sudo cp -rfT "$SRC/oxocarbon-death" /usr/share/sddm/themes/oxocarbon-death
##########################################################################
# END OF SCRIPT                                                          #
##########################################################################
