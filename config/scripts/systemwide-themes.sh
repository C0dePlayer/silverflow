#!/usr/bin/env bash

set -euo pipefail

readonly FILES_ROOT="/tmp/config/files"
readonly ICONS_DIR="/usr/share/icons"
readonly MOREWAITA_DIR="$ICONS_DIR/MoreWaita"
readonly MOREWAITA_MAIN_DIR="$MOREWAITA_DIR-main"
readonly URLS=("https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
    "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz"
    "https://github.com/lassekongo83/adw-gtk3/releases/latest/download/adw-gtk3$(curl -sL https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest | jq -r ".tag_name").tar.xz"
    "https://github.com/somepaulo/MoreWaita/archive/refs/heads/main.zip")

download_and_unpack() {
    local url=$1
    local filename
    local directory_name=""

    filename=$(basename "$url")

    curl -Lo "${FILES_ROOT}/$filename" "$url"
    echo "Unpacking $filename in $FILES_ROOT"

    if [[ $filename =~ \.tar\.xz$ ]]; then
        directory_name=${filename%.*.*}
        tar -xf "${FILES_ROOT}/$filename"
    elif [[ $url == *"MoreWaita/archive/refs/heads/main.zip" ]]; then
        directory_name="MoreWaita-main"
        unzip -qq "${FILES_ROOT}/$filename"
    fi

    if [[ -d "$directory_name" ]]; then
        echo "Copying $directory_name to $ICONS_DIR"
        cp -r "$directory_name" "$ICONS_DIR"
    fi
}

# Just in case
mkdir -p "$FILES_ROOT"
mkdir -p "$ICONS_DIR"

cd "$FILES_ROOT" || exit

for url in "${URLS[@]}"; do
    download_and_unpack "$url"
done

find "$MOREWAITA_MAIN_DIR" \( -name "*.build" -o -name "*.sh" -o -name "*.md" -o -name "*.py" -o -name "*.git" \) -type f -delete
rm -rf "$MOREWAITA_MAIN_DIR/main.zip" "$MOREWAITA_MAIN_DIR/_dev" "$MOREWAITA_MAIN_DIR/.github" "$MOREWAITA_MAIN_DIR/.gitignore"
mv "$MOREWAITA_MAIN_DIR" "$MOREWAITA_DIR"

gtk-update-icon-cache -f -t "$MOREWAITA_DIR"
xdg-desktop-menu forceupdate

cp -r "adw-gtk3" "${ICONS_DIR}"
cp -r "adw-gtk3-dark" "${ICONS_DIR}"
