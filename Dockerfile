FROM alpine:3.21

RUN mkdir -p \
        /config/ssh \
        /config/users \
    && apk add --no-cache \
        bash \
        borgbackup \
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
