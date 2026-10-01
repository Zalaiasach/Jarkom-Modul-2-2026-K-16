ip link set eth0 up
ip addr flush dev eth0
ip addr add 192.219.x.x/24 dev eth0
ip route replace default via 192.219.x.1 dev eth0
echo "nameserver 192.168.122.1" > /etc/resolv.conf