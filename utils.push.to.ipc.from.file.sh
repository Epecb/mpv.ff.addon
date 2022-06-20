#!/usr/bin/env bash

if [[ -z $1 ]]; then
    printf 'fail\n%s: file_with_command_to_ipc\ngrab from /dev/shm/mpv.log.url.txt\n' "$0"
    exit
fi

while read -r line; do
    echo "${line}" | socat - /tmp/mpvsocket
done < <(sed '/^$/d' "$1")
