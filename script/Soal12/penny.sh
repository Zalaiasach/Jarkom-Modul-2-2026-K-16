# 1. Pasang paket utilitas Apache
apt update && apt install -y apache2-utils

# 2. Buat file kredensial untuk user prabs (masukkan password saat diminta)
htpasswd -c /etc/apache2/.htpasswd prabs

# 3. Tambahkan blok konfigurasi proteksi Location /admin
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

    # Proteksi Basic Authentication untuk path /admin
    <Location /admin>
        AuthType Basic
        AuthName "Area Rahasia Sindikat K-16"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>
</VirtualHost>
EOF

# 4. Restart Apache untuk menerapkan konfigurasi
service apache2 restart