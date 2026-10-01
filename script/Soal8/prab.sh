# Deklarasi Zona Reverse pada named.conf.local
cat << 'EOF' >> /etc/bind/named.conf.local
zone "1.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.219.1";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};

zone "2.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.219.2";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};

zone "3.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.219.3";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};
EOF

# File Database PTR Area Server (Vault & Core)
cat << 'EOF' > /etc/bind/zones/db.192.219.1
$TTL 604800
@ IN SOA prab.k16.com. root.k16.com. ( 2026092801 604800 86400 2419200 604800 )
@ IN NS prab.k16.com.
@ IN NS tedd.k16.com.
4 IN PTR obladi.k16.com.
5 IN PTR desmond.k16.com.
6 IN PTR oblada.k16.com.
7 IN PTR molly.k16.com.
EOF

# File Database PTR Abbey
cat << 'EOF' > /etc/bind/zones/db.192.219.2
$TTL 604800
@ IN SOA prab.k16.com. root.k16.com. ( 2026092801 604800 86400 2419200 604800 )
@ IN NS prab.k16.com.
@ IN NS tedd.k16.com.
2 IN PTR abbey.k16.com.
EOF

# File Database PTR Penny
cat << 'EOF' > /etc/bind/zones/db.192.219.3
$TTL 604800
@ IN SOA prab.k16.com. root.k16.com. ( 2026092801 604800 86400 2419200 604800 )
@ IN NS prab.k16.com.
@ IN NS tedd.k16.com.
2 IN PTR penny.k16.com.
EOF

rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null