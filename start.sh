#!/bin/sh

# config caddy
mkdir -p /etc/caddy/ /usr/share/caddy
wget ${CADDYIndexPage:="https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html"} -O /usr/share/caddy/index.html 
wget ${CADDYCONFIG:="https://raw.githubusercontent.com/Tarukas/heroku/master/etc/Caddyfile"} -O /etc/caddy/Caddyfile 
sed -i -e "1c :$PORT" -e "s/\$SSPATH$/\\$SSPATH/" -e "s/\$GOSTPATH$/\\$GOSTPATH/" -e "s/\$BROOKPATH$/\\$BROOKPATH/" -e "s/\$V2RAYPATH$/\\$V2RAYPATH/" /etc/caddy/Caddyfile

# config v2ray
wget -O /v2ray.json ${V2RAYCONFIG:="https://raw.githubusercontent.com/Tarukas/heroku/master/etc/v2ray.json"}
sed -i -e "s/\$V2RAYPROTOCOL/$V2RAYPROTOCOL/" -e "s/\$AUUID/$AUUID/" -e "s/\$V2RAYPATH/\\$V2RAYPATH/" /v2ray.json

# start
[[ "$TOREnable"      ==    "true" ]]    &&    tor &

[[ "$V2RAYEnable"    ==    "true" ]]    &&    /v2ray -config /v2ray.json &

[[ "$BROOKEnable"    ==    "true" ]]    &&    brook wsserver -l 127.0.0.1:3234 --path $BROOKPATH -p $APASSWORD &

[[ "$GOSTEnable"     ==    "true" ]]    &&    gost ${GOSTMETHOD:="-L=ss+ws://AEAD_CHACHA20_POLY1305:$APASSWORD@127.0.0.1:2234?path=$GOSTPATH"} &

[[ "$SSEnable"       ==    "true" ]]    &&    ss-server -s 127.0.0.1 -p 1234 -k $APASSWORD -m $SSENCYPT --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=$SSPATH" &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
