#!/bin/sh

### update
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && apk update && apk add --no-cache ca-certificates

### caddy
apk add --no-cache caddy
mkdir -p /usr/share/caddy && wget -O /usr/share/caddy/index.html $CADDYIndexPage
cat << EOF > /etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server

@websocket_ss {
header Connection *Upgrade*
header Upgrade    websocket
path $SSPATH
}
reverse_proxy @websocket_ss 127.0.0.1:1234

@websocket_gost {
header Connection *Upgrade*
header Upgrade    websocket
path $GOSTPATH
}
reverse_proxy @websocket_gost 127.0.0.1:2234

@websocket_brook {
header Connection *Upgrade*
header Upgrade    websocket
path $BROOKPATH
}
reverse_proxy @websocket_brook 127.0.0.1:3234

@websocket_v2ray {
header Connection *Upgrade*
header Upgrade    websocket
path $V2RAYPATH
}
reverse_proxy @websocket_v2ray 127.0.0.1:4234
EOF

[[ "$CADDYCONFIG" != "" ]] && wget -O /etc/caddy/Caddyfile $CADDYCONFIG && sed -i "1c :$PORT" /etc/caddy/Caddyfile

nohup caddy run --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null 2>&1 &

### tor
[[ "$TOREnable" == "true" ]] && apk add --no-cache tor && nohup tor >/dev/null 2>&1 &

### v2ray
if [[ "$V2RAYEnable" == "true" ]]; then
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - && chmod +x /v2ray /v2ctl
    cat << EOF > /v2ray.json
{
    "inbounds": 
    [
        {
            "port": 4234,"listen": "127.0.0.1","protocol": "$V2RAYPROTOCOL",
            "settings": {"clients": [{"id": "$AUUID"}],"decryption": "none"},
            "streamSettings": {"network": "ws","wsSettings": {"path": "$V2RAYPATH"}}
        }
    ],
    "outbounds": [{"protocol": "freedom"}]
}   
EOF
    [[ "$V2RAYCONFIG" != "" ]] && wget -O /v2ray.json $V2RAYCONFIG
    nohup /v2ray -config /v2ray.json >/dev/null 2>&1 &
fi

### shadowsocks
if [[ "$SSEnable" == "true" ]]; then
    apk add --no-cache shadowsocks-libev
    v2rayplugin_URL="$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")"
    wget -O - $v2rayplugin_URL | tar -xz -C /usr/bin/ && chmod +x /usr/bin/v2ray-plugin_linux_amd64
    nohup ss-server -s 127.0.0.1 -p 1234 -k $APASSWORD -m $SSENCYPT --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=$SSPATH" >/dev/null 2>&1 &
fi

### gost
if [[ "$GOSTEnable" == "true" ]]; then
    gost_URL="$(wget -qO- https://api.github.com/repos/ginuerzh/gost/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")"
    wget -O - $gost_URL | gzip -d > /usr/bin/gost && chmod +x /usr/bin/gost
    [[ "$GOSTMETHOD" == "" ]] && nohup gost -L ss+ws://AEAD_CHACHA20_POLY1305:$APASSWORD@127.0.0.1:2234?path=$GOSTPATH >/dev/null 2>&1 & || nohup gost $GOSTMETHOD >/dev/null 2>&1 &
fi

### brook
if [[ "$BROOKEnable" == "true" ]]; then
    wget -O /usr/bin/brook https://github.com/txthinking/brook/releases/latest/download/brook_linux_amd64 && chmod +x /usr/bin/brook
    nohup brook wsserver -l 127.0.0.1:3234 --path $BROOKPATH -p $APASSWORD >/dev/null 2>&1 &
fi
