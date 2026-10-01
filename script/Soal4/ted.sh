apt update && apt install -y bind9 bind9utils dnsutils

cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

cat << 'EOF' > /etc/bind/named.conf.local
zone "k16.com" {
    type slave;
    file "/var/cache/bind/db.k16.com";
    masters { 192.219.1.2; };
    allow-transfer { any; };
};
EOF

chmod 775 /var/cache/bind
service named restart 2>/dev/null || service bind9 restart 2>/dev/null