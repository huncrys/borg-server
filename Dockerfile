# syntax=docker/dockerfile:1

FROM alpine:3.24@sha256:71e9b7bae160ba167fa17414401b94cbcdaf3c32feeab9298bd794a2a0614c35

# renovate: datasource=repology depName=alpine_3_24/borgbackup versioning=loose
ARG BORG_VERSION=1.4.5-r0

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
