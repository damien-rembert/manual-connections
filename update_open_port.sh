#!/bin/bash

# read open_port and current_port and assign them to vars
current_port=$(cat current_port)
open_port=$(cat open_port)
qb_listen_port=$(curl -s http://localhost:7676/api/v2/app/preferences | jq '.listen_port')

if [ $current_port -eq $open_port ]; then
    echo 'The current port is open in UFW.'
    if [ ! $current_port -eq $qb_listen_port ]; then 
        echo 'Wrong QB port. Changing now.'
        curl -s -d "json=%7B%22listen_port%22%3A$current_port%7D" http://localhost:7676/api/v2/app/setPreferences
    fi
else
    echo 'Changing port.'
    ufw delete allow $open_port/udp
    ufw delete allow $open_port/tcp && echo "" > open_port
    ufw allow $current_port/udp
    ufw allow $current_port/tcp && echo $current_port > open_port
    curl -s -d "json=%7B%22listen_port%22%3A$current_port%7D" http://localhost:7676/api/v2/app/setPreferences
fi

