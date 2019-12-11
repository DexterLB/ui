#!/bin/zsh
cdir="$(dirname "$0")"
. "${cdir}/visual.sh"

if [[ -n "${1}" ]]; then
    screenshot_type="${1}"
else
    echo \
"full screenshot
window screenshot
region screenshot
cancel" | rofi ${rofi_common[@]} -dmenu -p "screenshot" \
        | read screenshot_type _
fi

filename="/tmp/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

if [[ "${DISPLAY_SERVER}" == wayland ]]; then
    case "${screenshot_type}" in
        full)
            grim "${filename}"
            ;;
        window)
            echo "cannot screenshot a window"
            exit 1
            ;;
        region)
            grim -g "$(slurp)" "${filename}"
            ;;
        *)
            echo "wut?"
            exit 1
            ;;
    esac
else
    case "${screenshot_type}" in
        full)
            option=
            ;;
        window)
            option=-u
            ;;
        region)
            option=-s
            ;;
        *)
            echo "wut?"
            exit 1
            ;;
    esac

    scrot -d 0.1 ${option} "${filename}"
fi

echo \
"leave it be in ${filename}
copy filename to clipboard
copy image to clipboard
serve it
delete it
cancel" | rofi ${rofi_common[@]} -dmenu -p "what to do with the screenshot" \
        | read action object _

case "${action}" in
    leave)
        ;;
    copy)
        case "${object}" in
            filename)
                if [[ "${DISPLAY_SERVER}" == wayland ]]; then
                    echo -n "${filename}" | wl-copy
                else
                    echo -n "${filename}" | xclip -sel clip
                fi
                ;;
            image)
                if [[ "${DISPLAY_SERVER}" == wayland ]]; then
                    cat "${filename}" | wl-copy
                else
                    cat "${filename}" | xclip -sel clip -t image/png
                fi
                ;;
            *)
                echo "copy whaaaaat?"
                exit 1
                ;;
        esac
        ;;
    serve)
        termite -e zsh -i -l -c "serve '${filename}' ; sleep 1"
        ;;
    delete)
        rm -f "${filename}"
        ;;
    *)
        echo "wut?"
        exit 1
        ;;
esac
