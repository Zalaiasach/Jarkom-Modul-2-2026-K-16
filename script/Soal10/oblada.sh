apt update && apt install -y nginx php-fpm php-cli
mkdir -p /var/www/html

echo '<?php echo "<h1>Beranda Oblada (Core)</h1><p><a href=\"/profil\">Akses Halaman Profil (URL Bersih)</a></p>"; ?>' > /var/www/html/index.php
echo '<?php echo "<h1>Halaman Profil Oblada</h1><p>Berhasil diakses dengan URL bersih tanpa akhiran .php</p><p><a href=\"/\">Kembali ke Beranda</a></p>"; ?>' > /var/www/html/profil.php

cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name oblada.k16.com core.k16.com;

    location / {
        try_files $uri $uri/ @rewrites;
    }

    location @rewrites {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

service php8.4-fpm start 2>/dev/null || service php*-fpm start 2>/dev/null
service nginx restart