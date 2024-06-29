#!/bin/bash

if [[ "$1" == "disable" ]]; then
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
  sysctl -w net.ipv6.conf.lo.disable_ipv6=1
elif [[ "$1" == "enable" ]]; then
  sysctl -w net.ipv6.conf.all.disable_ipv6=0
  sysctl -w net.ipv6.conf.default.disable_ipv6=0
  sysctl -w net.ipv6.conf.lo.disable_ipv6=0
elif [[ "$1" == "self-install" ]]; then
  SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
  cp "$0" ~/.local/bin/manage-ipv6
else
  echo "$0 {enable|disable|self-install}"
  exit
fi

