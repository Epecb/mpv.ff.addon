#!/usr/bin/env bash

pth="$(pwd)"
cd /dev/shm
name="$(date +"%d-%m-%Y_%H-%M").tar"
tar cf "${name}"  mpv.log.url.txt mpv.server.error.log.html mpv.server.log.html

cd "${pth}"
7z -sdel a arch.7z "/dev/shm/${name}"

echo "${name}"
