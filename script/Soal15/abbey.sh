# 1. Buat direktori dan berkas HTML untuk path /orion (statis murni)
mkdir -p /var/www/orion
echo "Halaman Orion Abbey - Murni Statis Tanpa PHP" > /var/www/orion/index.html

# 2. Konfigurasi Nginx untuk menyajikan jalur /orion tanpa modul PHP
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location /orion {
        alias /var/www/orion;
        index index.html index.htm;
        try_files $uri $uri/ =404;
    }
}
EOF

# 3. Terapkan dan reload Nginx
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t && service nginx reload