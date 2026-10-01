# Praktikum Jarkom Modul II
|Nama|NRP|
|---|---|
|Afriezal Suryapraba Laiasach|5027251096|
|||
## Soal 1-2
Pada soal 1-2, kita akan melakukan setup awal mulai dari pemasangan node,NAT, dan Switch   
![node](/img/Soal1/Soal1.png)   
Setelah membuat sesuai dengan perintah soal, kita akan setup agar setiap node bisa tersambung ke internet. Pertama kita tambahkan script di node rootkit dengan
```sh
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
```   
Dengan ini node rootkit akan bekerja sebagai router dari node-node lain, yang kemudian setiap node ditambahkan script berikut:   
```sh
ip link set eth0 up
ip addr flush dev eth0
ip addr add 192.219.x.x/24 dev eth0
ip route replace default via 192.219.x.1 dev eth0
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```   
Dengan ini kita bisa tes apakah sudah tersambung dengan internet menggunakan perintah ```ping -c 2 8.8.8.8``` dan mencoba apakah sudah bisa menyambung ke node lain dengan perintah ```
## Soal 3
Pada soal ini, kita akan Pastikan seluruh node dapat saling terhubung dan berkomunikasi lintas jalur (routing internal via rootkit berfungsi). Untuk menghindari fragmentasi saat persiapan, pastikan setiap host non-router menambahkan resolver 192.168.122.1. Akan kita lakukan dengan:   
```sh
cat << 'EOF' > /etc/resolv.conf
nameserver 192.168.122.1
EOF
```   
Kita bisa tes dengan melakukan perintah misal ```ping -c 2 192.219.1.2``` di salah satu node selain node dengan ip 192.219.1.2 untuk mencoba apakah antar node sudah dapat tersambung.   
![bukti](/img/Soal3/bukti.png)   
## Soal 4
Pada soal ini, pada node prab, kita akan membangun zona k16.com sebagai authorative dengan SOA yang menuju ke prab.k16.com, lalu tambahkan catatan NS untuk prab.k16.com dan tedd.k16.com.  Buat A record untuk prab.k16.com dan tedd.k16.com yang mengarah ke alamat IP mereka masing-masing, serta A record apex k16.com yang mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona k16.com dari master dan pastikan server menjawab secara authoritative. Setelah fondasi nama ini berdiri kokoh, perbarui urutan resolver pada seluruh Entitas non-router menjadi: IP prab, IP tedd, lalu 192.168.122.1. Verifikasi bahwa query ke domain apex maupun hostname di dalam zona dijawab dengan benar oleh prab atau tedd.   
Script yang dibutuhkan untuk node prab adalah:
```sh
apt update && apt install -y bind9 bind9utils dnsutils

# Konfigurasi Options
cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

# Deklarasi Zona Master k16.com
cat << 'EOF' > /etc/bind/named.conf.local
zone "k16.com" {
    type master;
    file "/etc/bind/zones/db.k16.com";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};
EOF

# Berkas Basis Data Zona Inisial
mkdir -p /etc/bind/zones
cat << 'EOF' > /etc/bind/zones/db.k16.com
$TTL    604800
@       IN      SOA     prab.k16.com. root.k16.com. (
                             2026092801 ; Serial
                                 604800 ; Refresh
                                  86400 ; Retry
                                2419200 ; Expire
                                 604800 ) ; Negative Cache TTL

@       IN      NS      prab.k16.com.
@       IN      NS      tedd.k16.com.

prab    IN      A       192.219.1.2
tedd    IN      A       192.219.1.3

; Apex Domain dialihkan ke IP Penny
@       IN      A       192.219.3.2
EOF

service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
Dan script untuk node tedd adalah:   
```sh
apt update && apt install -y bind9 bind9utils dnsutils

cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

cat << 'EOF' > /etc/bind/named.conf.local
zone "k16.com" {
    type slave;
    file "/var/cache/bind/db.k16.com";
    masters { 192.219.1.2; };
    allow-transfer { any; };
};
EOF

chmod 775 /var/cache/bind
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
yang dimana akan kita tes di salah satu node dengan perintah
```sh
dig @192.219.1.2 k16.com
dig @192.219.1.3 k16.com
```
Yang dimana jika berhasil akan mengeluarkan output:   
![output](/img/Soal4/1.png)
![output2](/img/Soal4/2.png)