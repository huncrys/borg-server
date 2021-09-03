#!/usr/bin/env bash

mkdir -p /config/ssh /config/users /backups
chmod 711 /backups

if [ ! -f /config/ssh/ssh_host_dsa_key ]; then
    ssh-keygen -A 2>&1 > /dev/null
    mv /etc/ssh/ssh*key* /config/ssh/
fi

ln -sf /config/ssh/* /etc/ssh

if [ "$1" = "/usr/sbin/sshd" ]; then

    for i in /config/users/*; do
        thisuser=$(basename "$i")
        if [ "x$thisuser" == "x*" ]; then
            echo "No users exist yet"
        else
            createuser "$thisuser" "$(cat "/config/users/$thisuser")" > /dev/null
        fi
    done
fi 

exec $@
