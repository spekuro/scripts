#!/usr/bin/env bash

status=`expressvpn status | grep Not | wc -l`

if [ $status == "0" ]; then
  echo "VPN OK | iconName=emblem-default"
else
  echo "VPN NOK | iconName=emblem-unreadable"
fi
echo "---"
echo "Connect | bash='expressvpn connect;status=0' | terminal=false | refresh=true"
echo "Disconnect | bash='expressvpn disconnect;status=1' | terminal=false | refresh=true"

