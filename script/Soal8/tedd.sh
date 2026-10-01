cat << 'EOF' >> /etc/bind/named.conf.local
zone "1.219.192.in-addr.arpa" { type slave; file "/var/cache/bind/db.192.219.1"; masters { 192.219.1.2; }; allow-transfer { any; }; };
zone "2.219.192.in-addr.arpa" { type slave; file "/var/cache/bind/db.192.219.2"; masters { 192.219.1.2; }; allow-transfer { any; }; };
zone "3.219.192.in-addr.arpa" { type slave; file "/var/cache/bind/db.192.219.3"; masters { 192.219.1.2; }; allow-transfer { any; }; };
EOF

rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null