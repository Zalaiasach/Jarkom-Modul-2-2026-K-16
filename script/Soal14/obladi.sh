# Tambahkan format log proxy_combined ke konfigurasi Apache
cat << 'EOF' >> /etc/apache2/apache2.conf

LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" proxy_combined
CustomLog ${APACHE_LOG_DIR}/access.log proxy_combined
EOF

service apache2 restart