#!/bin/bash

NAME="Cloudflare"
declare -a IP_URLS=("https://www.cloudflare.com/ips-v4/" "https://www.cloudflare.com/ips-v6/")

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
echo "🕒 Current timestamp: $TIMESTAMP"
echo ""

echo "➕ Adding new Cloudflare UFW rules..."
RULE_COUNT=0
for IP_URL in "${IP_URLS[@]}"; do
	echo "   📡 Fetching IPs from $(basename $IP_URL)..."
	IPS=$(curl -s $IP_URL)
	while IFS= read -r IP; do
		ufw allow from $IP proto tcp to any port 80,443 comment "$NAME - HTTP/HTTPS - $TIMESTAMP" >/dev/null 2>&1
		ufw allow from $IP proto udp to any port 80,443 comment "$NAME - HTTP/HTTPS QUIC - $TIMESTAMP" >/dev/null 2>&1
		RULE_COUNT=$((RULE_COUNT + 2))
		echo "   ✓ Added rules for $IP"
	done < <(printf '%s' "$IPS")
done
echo "   📊 Total rules added: $RULE_COUNT"

echo ""
echo "🗑️  Removing outdated Cloudflare rules..."
RULES_DESC=$(ufw status numbered | grep "$NAME" | grep -v "$TIMESTAMP" | awk -F"[][]" '{print $2}' | tr --delete [:blank:] | sort -rn)
if [ -z "$RULES_DESC" ]; then
	echo "   ℹ️  No outdated rules found to remove"
else
	DELETED_COUNT=0
	for NUM in $RULES_DESC; do
		echo "   🔥 Deleting rule #$NUM"
		ufw -f delete $NUM >/dev/null 2>&1
		DELETED_COUNT=$((DELETED_COUNT + 1))
	done
	echo "   📊 Total rules deleted: $DELETED_COUNT"
fi

echo ""
echo "🔄 Reloading UFW configuration..."
ufw reload >/dev/null 2>&1
echo "   ✓ UFW configuration reloaded"
echo ""
echo "✅ Cloudflare UFW rules updated successfully!"
echo "   📅 Timestamp: $TIMESTAMP"
