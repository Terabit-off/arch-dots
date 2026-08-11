#!/bin/sh

DIR="$HOME/Pictures/Screenshots"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

grim -g "$(slurp)" "$FILE" || exit 0

ACTION=$(notify-send \
    -u low \
    -i "$FILE" \
    -A "open=Open" \
    -h boolean:resident:true \
    "Screenshot" \
    "Saved and copied")

if [ "$ACTION" = "open" ]; then
    swayimg "$FILE"
fi