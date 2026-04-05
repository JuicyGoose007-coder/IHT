#!/bin/bash
set -e

REPO="https://github.com/JuicyGoose007-coder/IHT.git"
DEST="$HOME/IHT"

# Cache sudo credentials before the long install
sudo -v

mkdir -p ~/.config ~/Pictures

if [ -d "$DEST" ]; then
  echo ">> $DEST already exists, pulling latest..."
  git -C "$DEST" pull
else
  echo ">> Cloning dotfiles..."
  git clone "$REPO" "$DEST"
fi

echo ">> Installing packages..."
bash "$DEST/scripts/pkgs.sh" || echo ">> Warning: some packages failed to install, continuing..."

echo ">> Unpacking dotfiles..."
cp "$DEST/zshrc" ~/.zshrc

for dir in starship fastfetch ghostty niri swaylock nvim yazi waybar tmux dunst wofi rofi wlogout; do
  cp -rfT "$DEST/$dir" ~/.config/$dir
done

cp -r "$DEST/wallpapers" ~/Pictures/
cp -rfT "$DEST/scripts" ~/scripts
cp -rfT "$DEST/Rust" ~/Rust

echo ">> Applying system configs (requires sudo)..."
sudo cp "$DEST/sddm.conf" /etc/sddm.conf

echo ">> Done! Dotfiles installed."
