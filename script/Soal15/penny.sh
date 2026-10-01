# 1. Buat direktori dan berkas PHP untuk path /eternal
mkdir -p /var/www/eternal
echo '<?php echo "<h1>Jalur Eternal Penny - PHP Rendered OK</h1>"; ?>' > /var/www/eternal/index.php

# 2. Konfigurasi Nginx untuk menangani jalur /eternal dengan PHP-FPM
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://192.219.1.7;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /eternal {
        alias /var/www/eternal;
        index index.php index.html index.htm;
        try_files $uri $uri/ =404;

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php-fpm.sock;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            include fastcgi_params;
        }
    }
}
EOF

# 3. Reload Nginx
nginx -t && service nginx reload