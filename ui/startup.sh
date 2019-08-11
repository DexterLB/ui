#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"
# . "${cdir}/interfaces.sh"

{
    # X settings
    xsetroot -cursor_name left_ptr

    "${cdir}/set_wallpaper.sh"

    export QT_STYLE_OVERRIDE='gtk2'
    export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

    pkill unclutter ; ( unclutter &>/dev/null ) &   # autohide pointer
    xset b off              # speakerectomy
    xset s off              # no screensaver
    xset s noblank          # no screen blanking
    xset -dpms              # no power saving
    # xset m 3/1 0            # mouse acceleration and speed
    xhost local:boinc       # allow boinc user to use GPU


    "${cdir}/klayout.sh"    # keyboard layout settings
    xcape -e 'Caps_Lock=Escape'
} &

{
    "${cdir}/detect_displays.sh"
} &

parcellite -n &>/dev/null &         # clipboard manager

systemctl --user stop redshift
systemctl --user start redshift

compton --no-fading-openclose --paint-on-overlay --glx-no-stencil -b -C -G
