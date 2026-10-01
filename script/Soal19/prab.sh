# 1. Tambahkan baris CNAME outbound yang mengarah ke domain eksternal badssl
cat << 'EOF' >> /etc/bind/zones/db.k16.com
outbound IN CNAME http.badssl.com.
EOF

# 2. Restart layanan BIND9
service named restart 2>/dev/null || service bind9 restart 2>/dev/null