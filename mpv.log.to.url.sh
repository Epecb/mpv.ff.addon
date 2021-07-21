#!/usr/bin/env bash

UF=${1}
UF=${UF:=/dev/shm/mpv.log.url.txt}
urlList=$(sed 's/^.*le","//;s/".*$//;/^$/d' "${UF}")

index=1
while read -r line; do
    title=$(youtube-dl --get-title "${line}")
    echo "stderr>> ${index} ${title}">&2
    printf "<a href=\"%s\">%s %s</a><br>\n" "${line}" "${index}" "${title}"
    let index+=1
done < <(printf "%s\n" "${urlList}")
