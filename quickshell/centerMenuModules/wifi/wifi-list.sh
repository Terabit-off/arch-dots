#!/usr/bin/env bash

# SSID -> autoconnect
declare -A saved_autoconnect

while IFS=: read -r name autoconnect; do
  saved_autoconnect["$name"]="$autoconnect"
done < <(nmcli -t -f NAME,AUTOCONNECT connection show)

# Вывод без заголовка, всё через :
nmcli -t -f IN-USE,SECURITY,SSID,SIGNAL,SECURITY device wifi list | \
while IFS=: read -r inuse sec ssid signal; do

  # connected
  [[ "$inuse" == "*" ]] && connected="yes" || connected="no"

  # security
  if [[ "$sec" == "--" ]]; then
    security="open"
  else
    if [[ -n "${saved_autoconnect[$ssid]+x}" ]]; then
      security="known"
    else
      security="locked"
    fi
  fi

  # autoconnect
  autoconnect="${saved_autoconnect[$ssid]}"
  [[ -z "$autoconnect" ]] && autoconnect="no"

  echo "${connected}:${security}:${ssid}:${signal}:${autoconnect}"
done