# 1. Aktifkan modul proxy dan load balancing Apache
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

# 2. Buat konfigurasi proxy load balancing ke klaster vault (obladi dan desmond)
cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
<VirtualHost *:80>
    ServerName penny.k16.com

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy balancer://vaultcluster>
        BalancerMember http://192.219.1.4 route=obladi
        BalancerMember http://192.219.1.5 route=desmond
        ProxySet lbmethod=byrequests
    </Proxy>

    # Meneruskan IP asli klien ke backend
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

# 3. Aktifkan situs dan restart layanan Apache
a2ensite penny-proxy.conf
service apache2 restart