# Ganti <NAMA_NODE> sesuai node: rootkit, alpha, beta, gamma, delta, epsilon, abbey, penny, obladi, desmond, oblada, molly
hostnamectl set-hostname <NAMA_NODE> 2>/dev/null || hostname <NAMA_NODE>
echo "<NAMA_NODE>" > /etc/hostname