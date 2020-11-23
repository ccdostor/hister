#!/bin/sh

# vars
MYUUID-HASH=$(caddy hash-password --plaintext $AUUID)

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$MYUUID-HASH/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGV2RAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/v2ray.json

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
cd /usr/share/caddy/$AUUID       && wget -i /usr/share/caddy/$AUUID/StoreFiles 

# start
tor &

/v2ray -config /v2ray.json &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile