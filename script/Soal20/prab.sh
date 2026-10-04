# 1. Kembalikan A record abbey ke kondisi normal tanpa TTL khusus
sed -i 's/^abbey.*/abbey IN A 192.219.2.2/g' /etc/bind/zones/db.k16.com

# 2. Aktifkan autostart BIND9 dan restart layanan
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
systemctl enable named 2>/dev/null || update-rc.d named defaults 2>/dev/null || update-rc.d bind9 defaults