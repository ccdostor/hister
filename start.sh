#!/bin/sh

# config caddy
mkdir -p /usr/share/caddy
wget -O /usr/share/caddy/index.html $IndexPage
cat << EOF > /etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server

$CADDYMORE

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

# config v2ray
cat << EOF > /v2ray.json
{
    "inbounds": 
    [
        {
            "port": 4234,"listen": "127.0.0.1","protocol": "vless",
            "settings": {"clients": [{"id": "$AUUID"}],"decryption": "none"},
            "streamSettings": {"network": "ws","wsSettings": {"path": "$V2RAYPATH"}}
        }
    ],
    "outbounds": [{"protocol": "freedom"}]
}	
EOF

[[ "$V2RAYCONFIG" != "" ]] && wget -O /v2ray.json $V2RAYCONFIG

# start
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
[[ "$TOREnable"      ==    "true" ]]    &&    tor &
[[ "$SSEnable"       ==    "true" ]]    &&    ss-server -s 127.0.0.1 -p 1234 -k $APASSWORD -m chacha20-ietf-poly1305 --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=$SSPATH" &
[[ "$GOSTEnable"     ==    "true" ]]    &&    gost -L ss+ws://AEAD_CHACHA20_POLY1305:$APASSWORD@127.0.0.1:2234?path=$GOSTPATH &
[[ "$BROOKEnable"    ==    "true" ]]    &&    brook wsserver -l 127.0.0.1:3234 --path $BROOKPATH -p $APASSWORD &
[[ "$V2RAYEnable"    ==    "true" ]]    &&    /v2ray -config /v2ray.json
