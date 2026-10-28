#!/bin/sh

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

# Выделяем область и делаем скриншот
GEOMETRY="$(slurp)" || exit 0
grim -g "$GEOMETRY" "$FILE" || exit 0

# Копируем PNG в clipboard
wl-copy --type image/png < "$FILE" &

# Показываем уведомление
ACTION=$(
    notify-send \
        -u low \
        -i "$FILE" \
        --action="open=Open" \
        --action="delete=Delete" \
        -h boolean:resident:true \
        "Screenshot" \
        "Saved and copied"
)

case "$ACTION" in
    open)
        swayimg "$FILE"
        ;;

    delete)
        rm -f "$FILE"
        ;;
esac