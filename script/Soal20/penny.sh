# Aktifkan autostart Nginx
service nginx restart
systemctl enable nginx 2>/dev/null || update-rc.d nginx defaults