#!/bin/bash

# this script will get prettier, I promise

function usage {
    echo "Usage: $0 username ssh-key"
}

# clean our username
function clean {
    STRING=$1
    CLEAN="${STRING//_/}" &&
        CLEAN="${CLEAN// /_}" &&
        CLEAN="${CLEAN//[^a-zA-Z0-9]/}" &&
        CLEAN="${CLEAN,,}"
    echo $CLEAN
}

if [ "x$1" == "x" ]; then
    usage
    exit 1
fi

if [ "x$2" == "x" ]; then
    usage
    exit 1
fi

# "scrub" the username
username=$(clean $1)

if [ ${#username} -gt 12 ]; then
    echo "Username cant be greater than 12 characters"
    exit 1
fi

job="unknown"
adduser -D -H -g "Borg Backup $username" $username -s /bin/rbash -h /backups/$username/ >/dev/null 2>&1
if [ $? == 0 ]; then
    mkdir -p /backups/$username/repo/
    job="created"
else
    # the assumption is a non-0 exit status is "user exists".. should really be a bit more checking on that
    job="checked"
    echo User exists, $username, enforcing settings
fi

# on alpine, for some reason the account is locked by default
passwd -u $username >/dev/null 2>&1

# we really should check $2 is what it says it is.
echo $2 >/opt/borgs/etc/users/$username

# make sure the user key is basically unmodifable
chown root:$username /opt/borgs/etc/users/$username
chmod 640 /opt/borgs/etc/users/$username

# make root own the user home directory, but group is for the user
chown root:$username /backups/$username

# make the user home directory un-readable by anyone except root
chmod 710 /backups/$username

# create the rbash profile (even if it already exists)
cp -f /opt/borgs/rbash_profile /backups/$username/.bash_profile

# make the profile unmodifable
chown root:root /backups/$username/.bash_profile

# allow the profile to be read by all
chmod 644 /backups/$username/.bash_profile

# ensure permissions for the repo directory are writable and owned by the user doing the backups
chown -R $username:$username /backups/$username/repo/

# set permissions for the user
chmod -R 770 /backups/$username/repo/

echo User $username $job, backup path is /backups/$username/repo/
