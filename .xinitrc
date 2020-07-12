export LC_ALL=en_US.UTF-8
export MM_CHARSET=UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
xrdb ~/.Xresources &
compton -b &
~/.screenlayout/home.sh; sleep 1; ~/.fehbg &
exec spectrwm
