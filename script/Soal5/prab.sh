cat << 'EOF' >> /etc/bind/zones/db.k16.com
rootkit IN      A       192.219.1.1
alpha   IN      A       192.219.4.2
beta    IN      A       192.219.4.3
gamma   IN      A       192.219.4.4
delta   IN      A       192.219.5.2
epsilon IN      A       192.219.5.3
abbey   IN      A       192.219.2.2
penny   IN      A       192.219.3.2
obladi  IN      A       192.219.1.4
desmond IN      A       192.219.1.5
oblada  IN      A       192.219.1.6
molly   IN      A       192.219.1.7
EOF

rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null