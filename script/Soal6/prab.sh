sed -i 's/allow-transfer.*/allow-transfer { 192.219.1.3; any; };/g' /etc/bind/named.conf.local
rndc reload