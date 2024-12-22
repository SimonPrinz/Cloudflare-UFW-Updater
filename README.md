# Cloudflare-UFW-Updater

```cron
# At 00:00 on Sunday.
0 0 * * 0 ./update-cloudflare-ufw.sh >> /tmp/cloudflare-ufw.log 2>&1
```
