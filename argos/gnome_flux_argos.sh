#!/usr/bin/env bash

path_to_script="~/Documents/scripts/gnome_flux.sh"
light=`gsettings get org.gnome.settings-daemon.plugins.color night-light-temperature | cut -d" " -f2`
location="lille"

echo "$light""k"" | iconName=preferences-color-symbolic"
echo "---"
echo "Classic profile | bash='$path_to_script -l $location -p classic' | terminal=false | refresh=true"
echo "Reduce_eyestrain profile | bash='$path_to_script -l $location -p reduce_eyestrain' | terminal=false | refresh=true"
echo "True_colors profile | bash='$path_to_script -l $location -p true_colors' | terminal=false | refresh=true"

