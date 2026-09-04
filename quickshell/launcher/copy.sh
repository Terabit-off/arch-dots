#!/bin/sh

set -eu

# Убираем пробелы и переводы строк из ID
id=$(printf '%s' "$1" | tr -d '[:space:]')
value=$"$2"

if [ -z "$id" ]; then
    exit 1
fi

entry=$(cliphist list | grep "^${id}[[:space:]]" || true)

if printf '%s\n' "$entry" | grep -q '\[\[ binary data '; then
    format=$(printf '%s\n' "$entry" |
        sed -n 's/.* \([a-zA-Z0-9+.-]*\) [0-9][0-9]*x[0-9][0-9]* \]\]$/\1/p')

    case "$format" in
        png)
            mime="image/png"
            ;;
        jpg|jpeg)
            mime="image/jpeg"
            ;;
        webp)
            mime="image/webp"
            ;;
        gif)
            mime="image/gif"
            ;;
        bmp)
            mime="image/bmp"
            ;;
        *)
            mime="application/octet-stream"
            ;;
    esac

    printf '%s' "$id" |
        cliphist decode |
        wl-copy --type "$mime"

    notify-send -u low "Image copied" "Clipboard"
else
    printf '%s' "$id" |
        cliphist decode |
        wl-copy --type text/plain

    notify-send -u low "Copied: '$2'" "Clipboard" 
fi