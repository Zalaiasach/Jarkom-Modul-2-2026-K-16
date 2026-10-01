apt update && apt install -y apache2
mkdir -p /var/www/html/arsip
echo "Dokumen arsip rahasia desmond" > /var/www/html/arsip/dokumen_b.txt

cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <Directory /var/www/html/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2enmod autoindex
service apache2 restart