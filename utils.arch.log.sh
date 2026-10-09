#!/usr/bin/env bash

pth="$(pwd)"
cd /dev/shm || (echo "cd Fail" ; exit 1)
ls
name="$(date +"%d-%m-%Y_%H-%M").tar"
prevFile="prev.tar"

tar cf "${name}"  mpv.log.url.txt mpv.server.error.log.html mpv.server.log.html

if [[ -a "${prevFile}" ]]; then
    echo "Prev file present"
    diff "${name}" "${prevFile}"
    if [ $? -eq 0 ]; then
        echo -e "\tequal"
        echo "Backup not needed. Remove tar. Exit. "
        rm "${name}"
        exit
    else
        echo -e "\tNot equal. Continue."
    fi
else
    echo "No file"
    echo -e "\tCopy. Continue."
    cp "${name}" "${prevFile}"
fi

cd "${pth}" || (echo "Return fail" ; exit 1)

7z -sdel a arch.7z "/dev/shm/${name}"

echo "${name}"
