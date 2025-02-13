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
    check_pid() {
        while true; do
            if [[ ! -d /proc/$mpv_pid ]]; then
               echo "exit"
               echo "exit" | nc 127.0.0.1 8888 -q 3
               exit
            fi
            sleep 5
            # echo "check $mpv_pid"
            # echo $$
        done
    }

    check_pid &
    firs_iter=1
    while [ "$(lsof -t /tmp/mpvsocket)" ]; do
        if [[ ${firs_iter} -eq 0 ]]; then
            logme &
        fi
        # echo "HTTP/1.0 200 OK" | nc -l -p 8888 | sed -un '/^POST/,/^\r/!p;$a \\' | tee -a /dev/shm/mpv.log.url.txt | socat - /tmp/mpvsocket
        echo "HTTP/1.0 200 OK" | nc -l 127.0.0.1  8888 | sed -un '/^POST/,/^\r/!p;$a \\' | tee -a /dev/shm/mpv.log.url.txt | socat - /tmp/mpvsocket
        firs_iter=0
    done
    wait
}


# mpv --no-osc --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format='best[height<=720]/bestvideo[height<=720]+bestaudio' --idle --input-ipc-server=/tmp/mpvsocket &
# mpv --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format='best[height<=720]/bestvideo[height<=720]+bestaudio' --idle --input-ipc-server=/tmp/mpvsocket &
# mpv --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format='best[height<=720][vcodec^=avc1]/bestvideo[height<=720][vcodec^=avc1]+bestaudio' --idle --input-ipc-server=/tmp/mpvsocket &

# https://gist.github.com/ftk/253347b2c9a53bbd6087f086970106b6
# ytproxy for fix ffmpeg bug
# mpv --http-proxy="http://127.0.0.1:12081" --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format='best[height<=720][vcodec^=avc1]/bestvideo[height<=720][vcodec^=avc1]+bestaudio' --idle --input-ipc-server=/tmp/mpvsocket &
# fix fps for laggy video with vaapi
mpv --http-proxy="http://127.0.0.1:12081" \
    --force-window=immediate \
    --osd-level=3 \
    --speed=3.22 \
    --ytdl-format='best[height<=720][vcodec^=avc1][fps<=40]/bestvideo[height<=720][vcodec^=avc1][fps<=40]+bestaudio' \
    --idle --input-ipc-server=/tmp/mpvsocket &
mpv_pid=$!
# echo $$
sleep 1


# control_fail_playback &

control_add_url
