FROM alpine:edge

ENV PORT                3000
ENV APASSWORD           password

ENV CADDYCONFIG         https://raw.githubusercontent.com/Tarukas/heroku/master/etc/Caddyfile
ENV CADDYIndexPage      https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html

ENV TOREnable           true

ENV GOSTEnable          true
ENV GOSTversion         2.11.1
ENV GOSTPATH            /gostpath

ENV BROOKEnable         true
ENV BROOKPATH           /brookpath

ENV SSEnable            true
ENV SSPLversion         1.3.1
ENV SSENCYPT            chacha20-ietf-poly1305
ENV SSPATH              /sspath

ENV V2RAYEnable         true
ENV V2RAYPROTOCOL       vless
ENV V2RAYPATH           /v2raypath
ENV AUUID               8f91b6a0-e8ee-11ea-adc1-0242ac120002
ENV V2RAYCONFIG         https://raw.githubusercontent.com/Tarukas/heroku/master/etc/v2ray.json

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk add --no-cache ca-certificates caddy tor shadowsocks-libev && \
    wget -O /usr/bin/brook https://github.com/txthinking/brook/releases/latest/download/brook_linux_amd64 && \
    wget -O - https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - && \
    wget -O - https://github.com/ginuerzh/gost/releases/download/v${GOSTversion}/gost-linux-amd64-${GOSTversion}.gz | gzip -d > /usr/bin/gost && \
    wget -O - https://github.com/shadowsocks/v2ray-plugin/releases/download/v${SSPLversion}/v2ray-plugin-linux-amd64-v${SSPLversion}.tar.gz | tar -xz -C /usr/bin/ && \
    chmod +x  /v2ray /v2ctl /usr/bin/gost /usr/bin/brook /usr/bin/v2ray-plugin_linux_amd64 && \
    rm -rf /var/cache/apk/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh
