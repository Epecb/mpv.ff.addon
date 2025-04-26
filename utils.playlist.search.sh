#!/usr/bin/env bash

cat /dev/shm/mpv.server.log.html | fzf | grep -A 1 -f - /dev/shm/mpv.server.log.html | sed 's/^<[^"]*"//;s/<[^>]*>//g;s/">/\t/'
