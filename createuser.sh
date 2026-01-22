#!/usr/bin/env bash

# this script will get prettier, I promise

set -euo pipefail

usage() {
    echo "Usage: $0 username ssh-key"
}

# clean our username
clean() {
    local username=$1
    username="${username//_/}"
    username="${username// /_}"
    username="${username//[^a-zA-Z0-9]/}"
    username="${username,,}"
    echo "$username"
}

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    usage
    exit 1
fi

# "scrub" the username
username=$(clean "$1")

if [[ ${#username} -gt 12 ]]; then
    echo "Username can't be longer than 12 characters"
    exit 1
fi

job="unknown"
if adduser -D -H -g "Borg Backup $username" "$username" -h "/backups/$username" >/dev/null 2>&1; then
    job="created"
else
    # the assumption is a non-0 exit status is "user exists".. should really be a bit more checking on that
    job="checked"
fi

mkdir -p "/backups/$username/repo"

# on alpine, for some reason the account is locked by default
passwd -u "$username" &> /dev/null

sshkey=$(sed -E 's/.*(ssh-.*)/\1/' <<<"$2")
echo "command=\"cd \\\"/backups/$username/repo\\\" && borg serve --restrict-to-path \\\"/backups/$username/repo\\\"\",restrict $sshkey" > /config/users/"$username"

# make sure the user key is basically unmodifable
chown "root:$username" "/config/users/$username"
chmod 640 "/config/users/$username"

# make root own the user home directory, but group is for the user
chown "root:$username" "/backups/$username"

# make the user home directory un-readable by anyone except root
chmod 710 "/backups/$username"

# ensure permissions for the repo directory are writable and owned by the user doing the backups
chown -R "$username:$username" "/backups/$username/repo"

# set permissions for the user
chmod -R 770 "/backups/$username/repo"

echo "User $username $job, backup path is /backups/$username/repo"
