#!/usr/bin/env sh

layout="$(cat /etc/vconsole.conf | grep XKBLAYOUT | awk -F'=' '{print toupper($2)}')"
printf "%s   " "$layout"
