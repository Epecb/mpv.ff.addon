#!/bin/sh

mpv --force-window=immediate --osd-level=3 --speed=2.42 --ytdl-format=best --idle --input-ipc-server=/tmp/mpvsocket &

while true; do
	echo "HTTP/1.0 200 OK" | nc -l -p 8888 | sed -un '/^POST/,/^\r/!p;a \\n' | socat - /tmp/mpvsocket
	# echo "HTTP/1.0 200 OK" | nc -l -p 8888 | sed -un '/^POST/,/^\r/!p;a \\n'
done
