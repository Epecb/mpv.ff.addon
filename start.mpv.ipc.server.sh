#!/usr/bin/env bash

control_fail_playback() {
    att=0

    logme() {
        local url
        local gettitle
        local nowdata
        url="$1"
        gettitle=$(yt-dlp --get-title "${url}")
        nowdata=$(LC_ALL=C date +"%A %B %D %R")
        printf "<a href=\"%s\">%s %s</a><br>\n" "${url}" "${nowdata}" "${gettitle}" >> /dev/shm/mpv.server.error.log.html
    }

    while read -r line; do
        unset id
        id=$(echo "$line" | sed -n '/error/p' | jq '.playlist_entry_id')
        if [[ $id != '' && $att != "$id" ]]; then
            att=${id}
            echo '{ "command": ["set_property", "pause", true] }'| socat - /tmp/mpvsocket
            errurl=$(echo '{ "command": ["get_property", "playlist"] }' | socat - /tmp/mpvsocket | jq -r --arg listID "${id}" '.data[] | select(.id == ($listID|tonumber)) | (.filename)')
            printf "%s %s\n" "$id" "$errurl"
            logme "${errurl}" &
            echo '{ "command": ["set_property", "options/ytdl-format", "bestvideo[height<=720]+bestaudio/best[height<=720]"] }' | socat - /tmp/mpvsocket
            # sleep 1
            printf '{ "command": ["set_property", "playlist-pos-1", %s] }\n' "${id}" | socat - /tmp/mpvsocket
            sleep 10
            echo '{ "command": ["set_property", "pause", false] }'| socat - /tmp/mpvsocket
            sleep 20
            echo '{ "command": ["set_property", "options/ytdl-format", "best[height<=720]/bestvideo[height<=720]+bestaudio"] }' | socat - /tmp/mpvsocket
        fi
    done < <(socat /tmp/mpvsocket -)
}


control_add_url() {
    logme(){
        lasturl=$(tail -n 2 /dev/shm/mpv.log.url.txt | sed 's/^.*le","//;s/".*$//;/^$/d')
        gettitle=$(yt-dlp --get-title "${lasturl}")
        nowdata=$(LC_ALL=C date +"%A %B %D %R")
        printf "%s\t%s %s\n" "${nowdata}" "${lasturl}" "${gettitle}"
        printf "<a href=\"%s\">%s %s</a><br>\n" "${lasturl}" "${nowdata}" "${gettitle}" >> /dev/shm/mpv.server.log.html
    }

    while [ "$(lsof -t /tmp/mpvsocket)" ]; do
        echo "HTTP/1.0 200 OK" | nc -l -p 8888 | sed -un '/^POST/,/^\r/!p;$a \\' | tee -a /dev/shm/mpv.log.url.txt | socat - /tmp/mpvsocket
        logme &
    done
}


mpv --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format='best[height<=720]/bestvideo[height<=720]+bestaudio' --idle --input-ipc-server=/tmp/mpvsocket &

sleep 1

control_fail_playback &

control_add_url
