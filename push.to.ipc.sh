#!/usr/bin/env bash

# grab from /dev/shm/mpv.log.url.txt

while read -r line; do
    echo "${line}" | socat - /tmp/mpvsocket
done < <(sed '/^$/d' "$1")
