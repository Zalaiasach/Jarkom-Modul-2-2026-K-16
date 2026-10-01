chmod 775 /var/cache/bind
rndc retransfer k16.com 2>/dev/null || rndc reload