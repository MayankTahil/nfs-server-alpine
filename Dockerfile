FROM hypriot/rpi-alpine
LABEL command "docker run -dt -v "
COPY Dockerfile /Dockerfile

RUN apk add -U -v nfs-utils bash iproute2 && \
    rm -rf /var/cache/apk/* /tmp/* && \
    rm -f /sbin/halt /sbin/poweroff /sbin/reboot && \
    mkdir -p /var/lib/nfs/rpc_pipefs && \
    mkdir -p /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
    echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab && \
    mkdir /data

COPY confd-binary /usr/bin/confd
COPY confd/confd.toml /etc/confd/confd.toml
COPY confd/toml/* /etc/confd/conf.d/
COPY confd/tmpl/* /etc/confd/templates/

COPY nfsd.sh /usr/bin/nfsd.sh
COPY .bashrc /root/.bashrc
COPY exports /etc/exports

RUN chmod +x /usr/bin/nfsd.sh /usr/bin/confd

ENV SHARED_DIRECTORY /data
ENTRYPOINT ["/usr/bin/nfsd.sh"]
