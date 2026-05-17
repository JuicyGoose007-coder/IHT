#!/bin/bash
set -euo pipefail

REPO="$(dirname "$(dirname "$(readlink -f "$0")")")"

echo ">> Installing SDDM oxocarbon-death theme..."
sudo mkdir -p /usr/share/sddm/themes/oxocarbon-death
sudo cp -f "$REPO/oxocarbon-death/Main.qml" /usr/share/sddm/themes/oxocarbon-death/
sudo cp -f "$REPO/oxocarbon-death/metadata.desktop" /usr/share/sddm/themes/oxocarbon-death/
sudo cp -f "$REPO/oxocarbon-death/theme.conf" /usr/share/sddm/themes/oxocarbon-death/

if [ -f "$REPO/oxocarbon-death/ComboBox.qml" ]; then
  echo ">> Installing custom ComboBox component..."
  sudo cp -f "$REPO/oxocarbon-death/ComboBox.qml" /usr/lib/qt6/qml/SddmComponents/ComboBox.qml
  if [ -d /usr/lib/qt/qml/SddmComponents ]; then
    sudo cp -f "$REPO/oxocarbon-death/ComboBox.qml" /usr/lib/qt/qml/SddmComponents/ComboBox.qml
  fi
fi

sudo cp -f "$REPO/sddm.conf" /etc/sddm.conf

echo ">> Done. Restart SDDM or reboot to apply changes."
