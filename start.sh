#!/bin/sh

# config caddy
cat << EOF > /etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server
@websocket_ss {
header Connection *Upgrade*
header Upgrade    websocket
path /sspath
}
reverse_proxy @websocket_ss 127.0.0.1:10000
EOF


# start
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
ss-server -s 127.0.0.1 -p 10000 -k password -m chacha20-ietf-poly1305 --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=/sspath"
