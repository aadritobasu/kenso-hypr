#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob  # so globs return empty array if no matches

# --- Step 1: Current Hyprland wallpaper file ---
HYPR_WALLPAPER_FILE="$HOME/.config/hypr/current_wallpaper"

if [[ ! -f "$HYPR_WALLPAPER_FILE" ]]; then
    echo "❌ Current wallpaper file not found: $HYPR_WALLPAPER_FILE"
    exit 1
fi

# --- Step 2: Current Catppuccin color ---
COLOR_FILE="$HOME/.config/matugen/papirus-folders/current-catppuccin-color.txt"

if [[ ! -f "$COLOR_FILE" ]]; then
    echo "❌ Current Catppuccin color file not found: $COLOR_FILE"
    exit 1
fi

CURRENT_COLOR=$(head -n1 "$COLOR_FILE" | tr -d '\0' | tr -d '\r')

if [[ -z "$CURRENT_COLOR" ]]; then
    echo "❌ Current Catppuccin color is empty in $COLOR_FILE"
    exit 1
fi

echo "Detected Catppuccin color: $CURRENT_COLOR"

# --- Step 3: Prepare destination folder ---
DEST_BASE="$HOME/Pictures/wallpapers"
DEST_FOLDER="$DEST_BASE/$CURRENT_COLOR"
mkdir -p "$DEST_FOLDER"

# --- Step 4: Detect extension (PNG or JPG) using hexdump ---
FILE_HEADER=$(head -c 8 "$HYPR_WALLPAPER_FILE" | hexdump -v -e '/1 "%02x"')

if [[ "$FILE_HEADER" == "89504e470d0a1a0a" ]]; then
    EXT="png"
elif [[ "${FILE_HEADER:0:4}" == "ffd8" ]]; then
    EXT="jpg"
else
    EXT="png"  # default
fi

# --- Step 5: Copy wallpaper with sequential name (per color, ignoring extension) ---
i=1
while :; do
    # Get all files starting with CURRENT_COLOR_
    files=("$DEST_FOLDER/${CURRENT_COLOR}_$i."*)
    if (( ${#files[@]} == 0 )); then
        break
    fi
    ((i++))
done

NEW_FILENAME="${CURRENT_COLOR}_$i.$EXT"

cp -- "$HYPR_WALLPAPER_FILE" "$DEST_FOLDER/$NEW_FILENAME"

echo "✔ Copied current wallpaper → '$DEST_FOLDER/$NEW_FILENAME'"
