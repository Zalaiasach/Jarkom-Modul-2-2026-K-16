# Aktifkan autostart BIND9 dan restart layanan
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
systemctl enable named 2>/dev/null || update-rc.d named defaults 2>/dev/null || update-rc.d bind9 defaults