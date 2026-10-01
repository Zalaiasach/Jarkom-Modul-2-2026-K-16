# 1. Ubah baris A record abbey dengan TTL 15 detik dan IP pengujian 192.219.2.222
sed -i 's/^abbey.*/abbey 15 IN A 192.219.2.222/g' /etc/bind/zones/db.k16.com

# 2. Naikkan serial SOA ke 2026100103 agar tersinkron ke tedd
sed -i 's/202610010[0-9]/2026100103/g' /etc/bind/zones/db.k16.com
service named restart 2>/dev/null || service bind9 restart 2>/dev/null