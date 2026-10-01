# Set Hostname
hostnamectl set-hostname rootkit 2>/dev/null || hostname rootkit
echo "rootkit" > /etc/hostname

# Konfigurasi Jaringan eth0 s/d eth5
ip link set eth0 up && udhcpc -i eth0
ip link set eth1 up && ip addr add 192.219.1.1/24 dev eth1 2>/dev/null
ip link set eth2 up && ip addr add 192.219.2.1/24 dev eth2 2>/dev/null
ip link set eth3 up && ip addr add 192.219.3.1/24 dev eth3 2>/dev/null
ip link set eth4 up && ip addr add 192.219.4.1/24 dev eth4 2>/dev/null
ip link set eth5 up && ip addr add 192.219.5.1/24 dev eth5 2>/dev/null

# Aktifkan IP Forwarding & IPTables NAT Masquerade
sysctl -w net.ipv4.ip_forward=1
iptables -P FORWARD ACCEPT
iptables -F FORWARD
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "nameserver 192.168.122.1" > /etc/resolv.conf