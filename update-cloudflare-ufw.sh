#!/bin/bash

NAME="Cloudflare"
declare -a IP_URLS=("https://www.cloudflare.com/ips-v4/" "https://www.cloudflare.com/ips-v6/")

RULES_DESC=$(ufw status numbered | grep "$NAME" | awk -F"[][]" '{print $2}' | tr --delete [:blank:] | sort -rn)
for NUM in $RULES_DESC; do
	yes | ufw delete $NUM
done

for IP_URL in "${IP_URLS[@]}"; do
	IPS=$(curl $IP_URL)
	while IFS= read -r IP; do
		ufw allow from $IP proto tcp to any port 80,443 comment "$NAME - HTTP/HTTPS"
		ufw allow from $IP proto udp to any port 80,443 comment "$NAME - HTTP/HTTPS QUIC"
	done < <(printf '%s' "$IPS")
done

ufw reload
