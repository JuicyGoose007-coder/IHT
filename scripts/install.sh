#!/bin/bash
##########################################################################
# _____ _   _               _____           _                            #
#|_   _| | | |             |_   _|         | |  DATE:XX/XX/XXXX          #
#  | | | |_| | __ ___   _____| | __ _ _ __ | |_ _ __ _   _ _ __ ___  ___ #
#  | | |  _  |/ _` \ \ / / _ \ |/ _` | '_ \| __| '__| | | | '_ ` _ \/ __|#
# _| |_| | | | (_| |\ V /  __/ | (_| | | | | |_| |  | |_| | | | | | \__ \#
# \___/\_| |_/\__,_| \_/ \___\_/\__,_|_| |_|\__|_|   \__,_|_| |_| |_|___/#
##########################################################################
# install script
##########################################################################

set -e

REPO="https://github.com/JuicyGoose007-coder/IHT.git"
DEST="$HOME/IHT"

echo ">> Ensuring directories exist..."
mkdir -p ~/.config ~/Pictures

echo ">> Cloning dotfiles..."
if [ -d "$DEST" ]; then
    echo ">> $DEST already exists, pulling latest..."
    git -C "$DEST" pull
else
    git clone "$REPO" "$DEST"
fi

echo ">> Installing packages..."
bash "$DEST/scripts/pkgs.sh" || echo ">> Warning: some packages failed to install, continuing..."

echo ">> Unpacking dotfiles..."
cp "$DEST/zshrc" ~/.zshrc
sudo cp "$DEST/sddm.conf" /etc/sddm.conf
cp -r "$DEST/starship" ~/.config/
cp -r "$DEST/fastfetch" ~/.config/
cp -r "$DEST/ghostty" ~/.config/
cp -r "$DEST/niri" ~/.config/
cp -r "$DEST/noctalia" ~/.config/
cp -r "$DEST/wallpapers" ~/Pictures/
cp -r "$DEST/swaylock" ~/.config/
cp -r "$DEST/nvim" ~/.config/
cp -r "$DEST/yazi" ~/.config/
cp -r "$DEST/waybar" ~/.config/
cp -r "$DEST/tmux" ~/.config/
cp -r "$DEST/dunst" ~/.config/
cp -r "$DEST/wofi" ~/.config/
cp -r "$DEST/rofi" ~/.config/
cp -r "$DEST/wlogout" ~/.config/
cp -r "$DEST/scripts" ~/
cp -r "$DEST/Rust" ~/

echo ">> Done! Dotfiles installed."

##########################################################################
# END OF SCRIPT                                                          #
##########################################################################
