# 1. Tambahkan data TXT Record klien ke dalam berkas zona
cat << 'EOF' >> /etc/bind/zones/db.k16.com

; TXT Records untuk Klien Sayap Kiri & Kanan
alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
EOF

# 2. Naikkan nomor serial SOA di db.k16.com dan restart DNS
sed -i 's/202610010[0-9]/2026100102/g' /etc/bind/zones/db.k16.com
service named restart 2>/dev/null || service bind9 restart 2>/dev/null