# docker-borg-backup-secure

Building on ginkels container, this is an attempt at making a docker container with added security for the borg backup software.

For more information about Borg Backup, an excellent deduplicating backup, refer to: <https://www.borgbackup.org/>

The idea behind this container is to stop users from being able to modify backups except by using the borg command, to achieve this the following occurs:

* all users get a rbash shell with borg being their only command
* all users run with a seperate UID - for my purposes, each server/workstation that backs up to this machine would be a seperate user

## Why?

Im very paranoid about push backups and those that occur over ssh without passwords are scary. Often i'll be backing up publicly hosted VM's and the idea they can just ssh back to an internal host really increased my fear factor. This is my attempt at making that as safe as possible.

Ultimately, i've found borg to be quite good so i think its worth the effort.

## Usage

The best tag to pull currently is alpine-multiarch-latest. As its name suggests its based on alpine and it supports most common architectures (386, x86_64, arm, arm64, etc). This tag is updated manually rather then being built from an autobuild on docker hub as I cannot figure out how to make autobuilt work on docker hub with multiple architectures! Ultimately alpine will become master soon enough as I'll exit the debian based image.

```shell
$ docker run --name borg -v <borg_backup_volume>:/backups -v <borg_user_list_location>:/opt/borgs/etc takigama/secured-borg-server:alpine-multiarch-latest
doing SSH key creation
```

To then create a user (or update their ssh key), run the following:

```shell
$ docker exec borg createuser
Usage: createuser username ssh-key
```

```shell
$ docker exec borg createuser john "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSkT3A1j89RT/540ghIMHXIVwNlAEM3WtmqVG7YN/wYwtsJ8iCszg4/lXQsfLFxYmEVe8L9atgtMGCi5QdYPl4X/c+5YxFfm88Yjfx+2xEgUdOr864eaI22yaNMQ0AlyilmK+asewfaszxcvzxcvzxcv+MCUWo+cyBFZVGOzrjJGEcHewOCbVs+IJWBFSi6w1enbKGc+RY9KrnzeDKWWqzYnNofiHGVFAuMxrmZOasqlTIKiC2UK3RmLxZicWiQmPnpnjJRo7pL0oYM9r/sIWzD6i2S9szDy6aZ john@host"
User john created, backup path is /backups/john/repo/
```

To delete a user - I might write a script for this, but currently this involes:

```shell
# if you wish to delete the user:
$ docker exec borg deluser <username>
# if you wish to delete their data:
$ docker exec borg rm -rf /backups/<username>            
# if you wish to delete their key:
$ docker exec borg rm -f /opt/borgs/etc/users/<username>
```

## Layout

The container users two volumes, /backups and /etc/borgs/etc/. If you want persistent data, you'll need both

* /etc/borgs/etc/users/$username - each is a pubkey for $username, ultimately its our list of active users
* /backups/$username - permission 0710 (user cant write in their own home directory or even see the files that exist there. Home directory is owned by root)
* /backups/$username/repo - loocation for actual backups (user writable/readable, should be the only location the user can actually see anything)

## Attributions

Based on the borg container by

* tgbyte - <https://github.com/tgbyte/docker-borg-backup>
* takigama - <https://github.com/takigama/docker-borg-backup>

## License

The files contained in this Git repository are licensed under the following license. This license explicitly does not cover the Borg Backup and Debian software packaged when running the Docker build. For these componensts, separate licenses apply that you can find at:

* <https://borgbackup.readthedocs.io/en/stable/authors.html#license>
* <https://www.debian.org/legal/licenses/>

Copyright 2018 TG Byte Software GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
