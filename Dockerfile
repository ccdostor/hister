FROM alpine:edge

ENV PORT        3000

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk add --no-cache ca-certificates caddy shadowsocks-libev && \
    
    v2rayplugin_URL="$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")" && \
    wget -O - $v2rayplugin_URL | tar -xz -C /usr/bin/ && \
    chmod +x /usr/bin/v2ray-plugin_linux_amd64 && \
    
    gost_URL="$(wget -qO- https://api.github.com/repos/ginuerzh/gost/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")" && \
    wget -O - $gost_URL | gzip -d > /usr/bin/gost && \
    chmod +x /usr/bin/gost && \
    
    brook_URL="$(wget -qO- https://api.github.com/repos/txthinking/brook/releases/latest | grep -E "browser_download_url.*linux_amd64" | cut -f4 -d\")" && \
    wget -O /usr/bin/brook $brook_URL && \
    chmod +x /usr/bin/brook


ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh
