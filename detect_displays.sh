#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

function get_displays {
    xrandr | grep '\bconnected\b' | cut -d' ' -f 1
}

function lid_open {
    for lid in /proc/acpi/button/lid/*/state; do
        if [[ "$(cat "${lid}")" =~ 'open' ]]; then
            return 0
        fi
    done

    return 1
}

function prioritise_displays {
    while read display; do
        if [[ "${display}" =~ '^eDP-?' ]]; then
            if lid_open; then
                echo "5 ${display}"
            else
                echo "-1 ${display}"    # turn off if lid is closed
            fi
        elif [[ "${display}" =~ '^DP-?' ]]; then
            echo "2 ${display}"         # displayPort has very high priority
        elif [[ "${display}" =~ '^HDMI-?' ]]; then
            echo "3 ${display}"         # hdmi has higher priority than laptop
        else
            echo "9 ${display}"        # unknown displays have lowest priority
        fi
    done
}

function sort_displays {
    sort -n
}

function set_displays {
    local previous=""

    while read priority display; do
        command="xrandr --output ${display}"
        
        if [[ "${priority}" -eq -1 ]]; then
            command="${command} --off"
        else
            if [[ -n "${previous}" ]]; then
                if [[ "${1}" == "clone" ]]; then
                    command="${command} --same-as ${previous} --auto"
                elif [[ "${1}" == "single" ]]; then
                    command="${command} --off"
                else
                    command="${command} --right-of ${previous} --auto"
                fi
            else
                command="${command} --primary --auto"
            fi

            previous="${display}"
        fi

        echo "executing: ${command}" 1>&2
        zsh -c "${command}"

        echo "${priority} ${display}"
    done
}

get_displays | prioritise_displays | sort_displays | set_displays single | sponge | set_displays "${@}" > /dev/null

"${cdir}/set_wallpaper.sh"
"${cdir}/klayout.sh"        # often a display comes with a keyboard
