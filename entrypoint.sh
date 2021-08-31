#!/bin/bash

mkdir -p /opt/borgs/etc/ssh/ >/dev/null 2>&1
mkdir -p /opt/borgs/etc/users/ >/dev/null 2>&1
if [ ! -f /opt/borgs/etc/ssh/ssh_host_dsa_key ]; then
    echo "doing SSH key creation"
    ssh-keygen -A
    mv /etc/ssh/ssh*key* /opt/borgs/etc/ssh/
    ln -sf /opt/borgs/etc/ssh/* /etc/ssh 2>/dev/null 2>&1
fi

mkdir -p /backups >/dev/null 2>&1
chmod 711 /backups

# check user list
echo "Start user check"
for i in /opt/borgs/etc/users/*; do
    thisuser=$(basename $i)
    if [ "x$thisuser" == "x*" ]; then
        echo "No users exist yet"
    else
        echo "Checking user $thisuser"
        createuser $thisuser "$(cat /opt/borgs/etc/users/$thisuser)"
    fi
done

exec /usr/sbin/sshd -D -e
