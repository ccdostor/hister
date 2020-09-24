FROM alpine:edge

ENV PORT        3000
ENV PV          1.3.1

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk add --no-cache caddy shadowsocks-libev && \
    wget -c https://github.com/shadowsocks/v2ray-plugin/releases/download/v${PV}/v2ray-plugin-linux-amd64-v${PV}.tar.gz -O - | tar -xz -C /usr/bin/ && \
    chmod +x /usr/bin/v2ray-plugin_linux_amd64

COPY start.sh /start.sh
RUN chmod +x /start.sh
