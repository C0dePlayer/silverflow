#!/usr/bin/env bash

set -euo pipefail

FILES_ROOT="/tmp/config/files"
ICONS_DIR="/usr/share/icons"
MOREWAITA_DIR="$ICONS_DIR/MoreWaita"
MOREWAITA_MAIN_DIR="$MOREWAITA_DIR-main"

unpack_and_copy() {
    local file=$1
    local extension=$2
    local directory_name
    directory_name=$(basename "${file}" ."${extension}")

    if [[ -f $file ]]; then
        echo "Unpacking ${file}"
        if [[ $extension == "tar.xz" ]]; then
            tar -xf "${file}"
        else
            unzip "${file}"
        fi
        echo "Copying ${directory_name} to ${ICONS_DIR}"
        cp -r "${directory_name}" "$ICONS_DIR"
    fi
}

# Just in case
mkdir -p "$FILES_ROOT"
mkdir -p "$ICONS_DIR"

wget -O "${FILES_ROOT}/Bibata-Modern-Ice.tar.xz" https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
wget -O "${FILES_ROOT}/Bibata-Modern-Classic.tar.xz" https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
wget -O "${FILES_ROOT}/MoreWaita-main.zip" https://github.com/somepaulo/MoreWaita/archive/refs/heads/main.zip

cd "${FILES_ROOT}" || exit

# Unpack and copy files
for f in *; do
    if [[ $f == *.tar.xz ]]; then
        unpack_and_copy "$f" "tar.xz"
    elif [[ $f == *.zip ]]; then
        unpack_and_copy "$f" "zip"
    fi
done

find "$MOREWAITA_MAIN_DIR" \( -name "*.build" -o -name "*.sh" -o -name "*.md" -o -name "*.py" -o -name "*.git" \) -type f -delete
rm -rf "$MOREWAITA_MAIN_DIR/main.zip" "$MOREWAITA_MAIN_DIR/_dev" "$MOREWAITA_MAIN_DIR/.github" "$MOREWAITA_MAIN_DIR/.gitignore"
mv "$MOREWAITA_MAIN_DIR" "$MOREWAITA_DIR"

gtk-update-icon-cache -f -t "$MOREWAITA_DIR"
xdg-desktop-menu forceupdate
