#!/bin/sh

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGV2RAY | sed "s/\$AUUID/$AUUID/g" >/v2ray.json

# start
[[ "$EnableTOR"      ==    "true" ]]    &&    tor &

[[ "$EnableV2RAY"    ==    "true" ]]    &&    /v2ray -config /v2ray.json &

[[ "$EnableBROOK"    ==    "true" ]]    &&    brook wsserver -l 127.0.0.1:3234 --path $AUUID-brook -p $AUUID &

[[ "$EnableGOST"     ==    "true" ]]    &&    eval gost $ParameterGOSTMETHOD &

[[ "$EnableSS"       ==    "true" ]]    &&    ss-server -s 127.0.0.1 -p 1234 -k $AUUID -m $ParameterSSENCYPT --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=/$AUUID-ss" &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile