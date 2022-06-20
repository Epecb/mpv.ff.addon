#!/usr/bin/env bash

# echo '{ "command": ["get_property", "playlist"] }' | socat - /tmp/mpvsocket | jq --arg listID "8" '.data[] | select(.id == ($listID|tonumber)) | (.filename)'
# echo '{ "command": ["set_property", "pause", true] }'| socat - /tmp/mpvsocket
# echo '{ "command": ["set_property", "pause", false] }'| socat - /tmp/mpvsocket
# echo '{ "command": ["get_property", "options/ytdl-format"] }' | socat - /tmp/mpvsocket | jq '.'
# "bestvideo[height<=720]+bestaudio/best[height<=720]" # slow
# "best[height<=720]/bestvideo[height<=720]+bestaudio" # default
# playlist-playing-pos

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
# done < log.error.txt
