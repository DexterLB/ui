#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"
# . "${cdir}/interfaces.sh"

{
    # X settings
    xsetroot -cursor_name left_ptr
    export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
    # unclutter &             # autohide pointer
    xset b off              # speakerectomy
    xset s off              # no screensaver
    xset s noblank          # no screen blanking
    xset -dpms              # no power saving
    # xset m 3/1 0            # mouse acceleration and speed
    xhost local:boinc       # allow boinc user to use GPU

    feh --bg-fill "${wallpaper}"

    "${cdir}/klayout.sh"    # keyboard layout settings
} &

{
    cd "${cdir}"/info
    ./info.py
} &

parcellite -n &>/dev/null &         # clipboard manager
