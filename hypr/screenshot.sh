#!/bin/sh

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

# Проверяем аргумент: область или весь экран
case "$1" in
    full)
        # Скриншот всего экрана (grim без флага -g)
        grim "$FILE" || exit 0
        ;;
    *)
        # По умолчанию: выделяем область
        GEOMETRY="$(slurp)" || exit 0
        grim -g "$GEOMETRY" "$FILE" || exit 0
        ;;
esac

# Копируем PNG в clipboard
wl-copy --type image/png < "$FILE" &

# Показываем уведомление
ACTION=$(
    notify-send \
        -u low \
        -i "$FILE" \
        --action="open=Open" \
        --action="folder=In Folder" \
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
    folder)
        nemo "$DIR"
        ;;
esac
