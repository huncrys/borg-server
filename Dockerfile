# syntax=docker/dockerfile:1

FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

# renovate: datasource=repology depName=alpine_3_23/borgbackup versioning=loose
ARG BORG_VERSION=1.4.4-r0

RUN mkdir -p \
        /config/ssh \
        /config/users \
    && apk add --no-cache \
        bash \
        borgbackup~"${BORG_VERSION%-r*}" \
        openssh-server \
        py3-packaging \
        tini \
        tzdata \
    && sed -i \
        -e 's/^#PasswordAuthentication.*$/PasswordAuthentication no/g' \
        -e 's/^#PermitRootLogin.*$/PermitRootLogin no/g' \
        -e 's/^X11Forwarding yes$/X11Forwarding no/g' \
        -e 's/^#LogLevel.*$/LogLevel INFO/g' \
        -e 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/g' \
        -e 's/^AuthorizedKeysFile.*$/AuthorizedKeysFile \/config\/users\/%u/g' \
        -e 's/^#ClientAliveInterval.*$/ClientAliveInterval 10/g' \
        -e 's/^#ClientAliveCountMax.*$/ClientAliveCountMax 30/g' \
        /etc/ssh/sshd_config

VOLUME ["/backups", "/config"]

COPY ./entrypoint.sh /
COPY ./createuser.sh /usr/sbin/createuser

EXPOSE 22
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
