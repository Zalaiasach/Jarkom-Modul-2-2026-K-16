# Tambahkan format log proxy_combined ke konfigurasi Nginx
sed -i '/http {/a \    log_format proxy_combined '\''$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'\'';\n    access_log /var/log/nginx/access.log proxy_combined;' /etc/nginx/nginx.conf

service nginx restart