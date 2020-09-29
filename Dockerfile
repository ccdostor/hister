FROM alpine:edge

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk add --no-cache ca-certificates caddy tor shadowsocks-libev && \
    v2rayplugin_URL="$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")" && \
    wget -O - $v2rayplugin_URL | tar -xz -C /usr/bin/ && \
    gost_URL="$(wget -qO- https://api.github.com/repos/ginuerzh/gost/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")" && \
    wget -O - $gost_URL | gzip -d > /usr/bin/gost && \
    wget -O /usr/bin/brook https://github.com/txthinking/brook/releases/latest/download/brook_linux_amd64 && \
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - && \
    chmod +x /v2ray /v2ctl /usr/bin/gost /usr/bin/brook /usr/bin/v2ray-plugin_linux_amd64  && \
    rm -rf /var/cache/apk/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh
