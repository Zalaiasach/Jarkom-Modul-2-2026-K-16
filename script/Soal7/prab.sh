cat << 'EOF' >> /etc/bind/zones/db.k16.com

; A Records Multi-IP
vault   IN      A       192.219.1.4
vault   IN      A       192.219.1.5
core    IN      A       192.219.1.6
core    IN      A       192.219.1.7

; CNAME Records
www     IN      CNAME   penny.k16.com.
static  IN      CNAME   abbey.k16.com.
EOF

sed -i 's/202609280[0-9]/2026092803/g' /etc/bind/zones/db.k16.com
rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null