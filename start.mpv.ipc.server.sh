#!/usr/bin/env sh


mpv --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format='best[height<=720]/bestvideo[height<=720]+bestaudio' --idle --input-ipc-server=/tmp/mpvsocket &
sleep 1

while [ "$(lsof -t /tmp/mpvsocket)" ]; do
	echo "HTTP/1.0 200 OK" | nc -l -p 8888 | sed -un '/^POST/,/^\r/!p;$a \\' | tee -a /dev/shm/mpv.log.url.txt | socat - /tmp/mpvsocket
done
