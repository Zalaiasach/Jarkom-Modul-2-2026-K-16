# Pastikan IP forwarding dan NAT iptables tersimpan permanen
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
netfilter-persistent save 2>/dev/null || iptables-save > /etc/iptables.rules