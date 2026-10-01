apt update && apt install -y bind9 bind9utils dnsutils

# Konfigurasi Options
cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

# Deklarasi Zona Master k16.com
cat << 'EOF' > /etc/bind/named.conf.local
zone "k16.com" {
    type master;
    file "/etc/bind/zones/db.k16.com";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};
EOF

# Berkas Basis Data Zona Inisial
mkdir -p /etc/bind/zones
cat << 'EOF' > /etc/bind/zones/db.k16.com
$TTL    604800
@       IN      SOA     prab.k16.com. root.k16.com. (
                             2026092801 ; Serial
                                 604800 ; Refresh
                                  86400 ; Retry
                                2419200 ; Expire
                                 604800 ) ; Negative Cache TTL

@       IN      NS      prab.k16.com.
@       IN      NS      tedd.k16.com.

prab    IN      A       192.219.1.2
tedd    IN      A       192.219.1.3

; Apex Domain dialihkan ke IP Penny
@       IN      A       192.219.3.2
EOF

service named restart 2>/dev/null || service bind9 restart 2>/dev/null