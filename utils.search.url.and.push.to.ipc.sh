#!/usr/bin/env bash

find_yt_id(){
    printf "%s" "$1" | sed 's/\\//g;s/^.*v=//;s/&.*$//'
}

if [[ "$1" == "x" ]]; then
    yt_id=$(find_yt_id "$(xclip -o)")
else
    printf "%s\n" "${1}"
    yt_id=$(find_yt_id "${1}")
fi

echo "${yt_id}"


pull_data="$(sed -n "/${yt_id}/,\$p" /dev/shm/mpv.log.url.txt)"

./utils.push.to.ipc.from.file.sh <(printf "%s" "${pull_data}")
# sed -n '/njeajRm_RIk/,$p' /dev/shm/mpv.log.url.txt > /dev/shm/tst.txt
