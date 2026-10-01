# Konfigurasi VirtualHost Nginx untuk temporary redirect (302) ke static.k16.com
cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
server {
    listen 80;
    server_name abbey.k16.com 192.219.2.2;

    # Redirect sementara (302) menuju static.k16.com
    return 302 http://static.k16.com$request_uri;
}
EOF

# Terapkan konfigurasi dan restart Nginx
ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/default
service nginx restart