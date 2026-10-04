# Konfigurasi VirtualHost Redirect 301 ke www.k16.com beserta VirtualHost utama
cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
# VirtualHost untuk redirect 301 permanen
<VirtualHost *:80>
    ServerName penny.k16.com
    ServerAlias 192.219.3.2
    Redirect 301 / http://www.k16.com/
</VirtualHost>

# VirtualHost utama www.k16.com
<VirtualHost *:80>
    ServerName www.k16.com

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy balancer://vaultcluster>
        BalancerMember http://192.219.1.4 route=obladi
        BalancerMember http://192.219.1.5 route=desmond
        ProxySet lbmethod=byrequests
    </Proxy>

    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    <Location /admin>
        AuthType Basic
        AuthName "Area Rahasia Sindikat K-16"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>
</VirtualHost>
EOF

# Restart Apache
service apache2 restart