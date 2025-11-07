# syntax=docker/dockerfile:1

FROM alpine:3.22@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

# renovate: datasource=repology depName=alpine_3_22/borgbackup versioning=loose
ARG BORG_VERSION=1.4.2-r0

RUN mkdir -p \
        /config/ssh \
        /config/users \
    && apk add --no-cache \
        bash \
        borgbackup="${BORG_VERSION}" \
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

ADD ./entrypoint.sh /
ADD ./createuser.sh /usr/sbin/createuser
RUN chmod a+x /usr/sbin/createuser

EXPOSE 22
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
