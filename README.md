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

## Soal 5
Pada soal ini Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly, dan verifikasi bahwa setiap host mengenali hostname tersebut secara system-wide. Buat setiap domain untuk masing-masing node sesuai dengan namanya (contoh: alpha.<xxxx>.com) dan assign IP masing-masing juga. 
Kode nya ialah:
```sh
hostnamectl set-hostname <NAMA_NODE> 2>/dev/null || hostname <NAMA_NODE>
echo "<NAMA_NODE>" > /etc/hostname
```
Kode ini digunakan untuk mengganti hostname
```sh
cat << 'EOF' >> /etc/bind/zones/db.k16.com
rootkit IN      A       192.219.1.1
alpha   IN      A       192.219.4.2
beta    IN      A       192.219.4.3
gamma   IN      A       192.219.4.4
delta   IN      A       192.219.5.2
epsilon IN      A       192.219.5.3
abbey   IN      A       192.219.2.2
penny   IN      A       192.219.3.2
obladi  IN      A       192.219.1.4
desmond IN      A       192.219.1.5
oblada  IN      A       192.219.1.6
molly   IN      A       192.219.1.7
EOF

rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null
``` 
Yang dimana kemudian hasilnya begini:   
![bukti](/img/Soal5/Pengujian.png)   
## Soal 6
Kita akan memastikan zone transfer berjalan, pastikan tedd telah menerima salinan zona terbaru dari prab. Nilai serial SOA di keduanya harus sama karena keduanya tidak bisa dipisahkan dan saling melengkapi.   
Begini kodenya untuk prab: 
```sh
sed -i 's/allow-transfer.*/allow-transfer { 192.219.1.3; any; };/g' /etc/bind/named.conf.local
rndc reload
```

Sementara itu begini bentuk kode tedd:
```sh
chmod 775 /var/cache/bind
rndc retransfer k16.com 2>/dev/null || rndc reload
```
Yang dimana hasilnya adalah:   
![bukti](/img/Soal6/dig.png/)   
![serial](/img/Soal6/Serial.png)   
## Soal 7
abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk vault.<xxxx>.com (IP obladi & desmond), dan core.<xxxx>.com (IP oblada & molly). Tetapkan CNAME:
www.<xxxx>.com → penny.<xxxx>.com
static.<xxxx>.com → abbey.<xxxx>.com
Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.
Seperti ini kode yang digunakan:   
```sh
cat << 'EOF' >> /etc/bind/zones/db.k16.com

; A Records Multi-IP
vault   IN      A       192.219.1.4
vault   IN      A       192.219.1.5
core    IN      A       192.219.1.6
core    IN      A       192.219.1.7

; CNAME Records
www     IN      CNAME   penny.k16.com.
static  IN      CNAME   abbey.k16.com.
EOF

sed -i 's/202609280[0-9]/2026092803/g' /etc/bind/zones/db.k16.com
rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```
Dan seperti ini kode untuk tedd:   
```sh
rndc retransfer k16.com 2>/dev/null || rndc reload
```   
Hasilnya untuk percobaan www dan static seperti ini:   
![ws](/img/Soal7/WwwStatic.png)   
Sementara percobaan vault core seperti ini:   
![vc](/img/Soal7/VaultCore.png)   

## Soal 8
Di prab (master) deklarasikan reverse zone untuk segmen jaringan tempat abbey, penny, area vault, dan area core berada. Di tedd (slave) tarik reverse zone tersebut sebagai slave, isi PTR untuk keempat hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat abbey, penny, area vault, dan area core dijawab authoritative.   
Script yang digunakan pada node prab adalah:   
```sh
# Deklarasi Zona Reverse pada named.conf.local
cat << 'EOF' >> /etc/bind/named.conf.local
zone "1.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.219.1";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};

zone "2.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.219.2";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};

zone "3.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.219.3";
    notify yes;
    also-notify { 192.219.1.3; };
    allow-transfer { 192.219.1.3; any; };
};
EOF

# File Database PTR Area Server (Vault & Core)
cat << 'EOF' > /etc/bind/zones/db.192.219.1
$TTL 604800
@ IN SOA prab.k16.com. root.k16.com. ( 2026092801 604800 86400 2419200 604800 )
@ IN NS prab.k16.com.
@ IN NS tedd.k16.com.
4 IN PTR obladi.k16.com.
5 IN PTR desmond.k16.com.
6 IN PTR oblada.k16.com.
7 IN PTR molly.k16.com.
EOF

# File Database PTR Abbey
cat << 'EOF' > /etc/bind/zones/db.192.219.2
$TTL 604800
@ IN SOA prab.k16.com. root.k16.com. ( 2026092801 604800 86400 2419200 604800 )
@ IN NS prab.k16.com.
@ IN NS tedd.k16.com.
2 IN PTR abbey.k16.com.
EOF

# File Database PTR Penny
cat << 'EOF' > /etc/bind/zones/db.192.219.3
$TTL 604800
@ IN SOA prab.k16.com. root.k16.com. ( 2026092801 604800 86400 2419200 604800 )
@ IN NS prab.k16.com.
@ IN NS tedd.k16.com.
2 IN PTR penny.k16.com.
EOF

rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
Dan script untuk node tedd adalah:   
```sh
cat << 'EOF' >> /etc/bind/named.conf.local
zone "1.219.192.in-addr.arpa" { type slave; file "/var/cache/bind/db.192.219.1"; masters { 192.219.1.2; }; allow-transfer { any; }; };
zone "2.219.192.in-addr.arpa" { type slave; file "/var/cache/bind/db.192.219.2"; masters { 192.219.1.2; }; allow-transfer { any; }; };
zone "3.219.192.in-addr.arpa" { type slave; file "/var/cache/bind/db.192.219.3"; masters { 192.219.1.2; }; allow-transfer { any; }; };
EOF

rndc reload || service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
Pengujian dilakukan dengan menjalankan perintah reverse lookup dari salah satu klien (delta):   
```sh
dig @192.219.1.2 -x 192.219.2.2 +short
dig @192.219.1.3 -x 192.219.3.2 +short
dig @192.219.1.3 -x 192.219.1.4 +short
dig @192.219.1.3 -x 192.219.1.5 +short
dig @192.219.1.3 -x 192.219.1.6 +short
dig @192.219.1.3 -x 192.219.1.7 +short
```   
Yang dimana hasilnya adalah:   
![bukti](/img/Soal8/dig.png)   

## Soal 9
Jalankan layanan web statis pada hostname di node area vault (menggunakan apache). Buka folder direktori /arsip/ dan aktifkan fitur autoindex (directory listing) pada konfigurasi Apache sehingga seluruh daftar file di dalamnya dapat ditelusuri langsung dari browser. Akses pengujian harus dilakukan melalui hostname, bukan IP address.   
Script untuk node obladi adalah:   
```sh
apt update && apt install -y apache2
mkdir -p /var/www/html/arsip
echo "Dokumen arsip rahasia obladi" > /var/www/html/arsip/dokumen_a.txt

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
```   
Dan script untuk node desmond adalah:   
```sh
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
```   
Pengujian dilakukan dari klien (delta) menggunakan curl ke hostname masing-masing:   
```sh
curl -s http://obladi.k16.com/arsip/ | grep -i "Index of"
curl http://obladi.k16.com/arsip/dokumen_a.txt
curl -s http://desmond.k16.com/arsip/ | grep -i "Index of"
curl http://desmond.k16.com/arsip/dokumen_b.txt
```   
Hasil pengujian pada obladi:   
![obladi](/img/Soal9/Obladi.png)   
Dan hasil pengujian pada desmond:   
![desmond](/img/Soal9/Desmond.png)   

## Soal 10
Jalankan layanan web dinamis (PHP-FPM) pada hostname di node core (menggunakan nginx). Buat sebuah aplikasi sederhana yang memuat halaman beranda dan halaman profil. Terapkan aturan rewrite pada server sehingga akses ke /profil dapat berfungsi dengan URL bersih (tanpa akhiran .php). Akses pengujian wajib dilakukan melalui hostname.   
Script untuk node oblada adalah:   
```sh
apt update && apt install -y nginx php-fpm php-cli
mkdir -p /var/www/html

echo '<?php echo "<h1>Beranda Oblada (Core)</h1><p><a href=\"/profil\">Akses Halaman Profil (URL Bersih)</a></p>"; ?>' > /var/www/html/index.php
echo '<?php echo "<h1>Halaman Profil Oblada</h1><p>Berhasil diakses dengan URL bersih tanpa akhiran .php</p><p><a href=\"/\">Kembali ke Beranda</a></p>"; ?>' > /var/www/html/profil.php

cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name oblada.k16.com core.k16.com;

    location / {
        try_files $uri $uri/ @rewrites;
    }

    location @rewrites {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

service php8.4-fpm start 2>/dev/null || service php*-fpm start 2>/dev/null
service nginx restart
```   
Dan script untuk node molly adalah:   
```sh
apt update && apt install -y nginx php-fpm php-cli
mkdir -p /var/www/html

echo '<?php echo "<h1>Beranda Molly (Core)</h1><p><a href=\"/profil\">Akses Halaman Profil (URL Bersih)</a></p>"; ?>' > /var/www/html/index.php
echo '<?php echo "<h1>Halaman Profil Molly</h1><p>Berhasil diakses dengan URL bersih tanpa akhiran .php</p><p><a href=\"/\">Kembali ke Beranda</a></p>"; ?>' > /var/www/html/profil.php

cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name molly.k16.com core.k16.com;

    location / {
        try_files $uri $uri/ @rewrites;
    }

    location @rewrites {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

service php8.4-fpm start 2>/dev/null || service php*-fpm start 2>/dev/null
service nginx restart
```   
Pengujian dilakukan dari klien (alpha dan delta) dengan mengakses halaman beranda dan `/profil`:   
```sh
# Di node alpha
curl http://oblada.k16.com/
curl http://oblada.k16.com/profil

# Di node delta
curl http://molly.k16.com/
curl http://molly.k16.com/profil
```   
Hasil pengujian pada oblada:   
![oblada](/img/Soal10/Oblada.png)   
Dan hasil pengujian pada molly:   
![molly](/img/Soal10/Molly.png)   

## Soal 11
Konfigurasikan Penny (menggunakan Apache) sebagai reverse proxy yang mengarah ke semua node di area vault (Obladi & Desmond). Sementara itu, konfigurasikan Abbey (menggunakan Nginx) sebagai reverse proxy menuju area core (Oblada & Molly). Pastikan kedua gerbang ini meneruskan identitas asli pengunjung ke server backend dengan melakukan forwarding header Host dan X-Real-IP. Buktikan bahwa Penny dan Abbey berhasil mendistribusikan lalu lintas dengan tepat.   
Script yang digunakan pada node Penny adalah:   
```sh
# 1. Aktifkan modul proxy dan load balancing Apache
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

# 2. Buat konfigurasi proxy load balancing ke klaster vault (obladi dan desmond)
cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
<VirtualHost *:80>
    ServerName penny.k16.com

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy balancer://vaultcluster>
        BalancerMember http://192.219.1.4 route=obladi
        BalancerMember http://192.219.1.5 route=desmond
        ProxySet lbmethod=byrequests
    </Proxy>

    # Meneruskan IP asli klien ke backend
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

# 3. Aktifkan situs dan restart layanan Apache
a2ensite penny-proxy.conf
service apache2 restart
```   
Dan pada node Abbey, reverse proxy dikonfigurasikan dengan meneruskan header Host serta X-Real-IP menuju backend:   
```sh
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;
    server_name _;

    location / {
        proxy_pass http://192.219.1.7;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

service nginx restart
```   
Berikut dokumentasi pengaktifan modul proxy Apache di Penny:   
![modul](/img/Soal11/Screenshot%202026-10-01%20231038.png)   
Konfigurasi virtualhost penny-proxy:   
![conf](/img/Soal11/Screenshot%202026-10-01%20231209.png)   
Serta pengaktifan site dan restart Apache pada Penny:   
![restart](/img/Soal11/Screenshot%202026-10-01%20231234.png)   

## Soal 12
Terdapat ruang khusus di penny yang yang menyimpan dokumen rahasia sindikat, oleh karena itu terapkan perlindungan basic authentication untuk path /admin. Akses ke jalur tersebut harus menolak pengunjung tanpa kredensial, dan hanya mengizinkan masuk jika menggunakan credential berikut:   
username: `prabs`   
password: `pakar_pinter_jadi_gob***`   
Script yang digunakan pada node Penny adalah:   
```sh
# 1. Pasang paket utilitas Apache
apt update && apt install -y apache2-utils

# 2. Buat file kredensial untuk user prabs (masukkan password saat diminta)
htpasswd -c /etc/apache2/.htpasswd prabs

# 3. Tambahkan blok konfigurasi proteksi Location /admin
cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
<VirtualHost *:80>
    ServerName penny.k16.com

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy balancer://vaultcluster>
        BalancerMember http://192.219.1.4 route=obladi
        BalancerMember http://192.219.1.5 route=desmond
        ProxySet lbmethod=byrequests
    </Proxy>

    # Meneruskan IP asli klien ke backend
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    # Proteksi Basic Authentication untuk path /admin
    <Location /admin>
        AuthType Basic
        AuthName "Area Rahasia Sindikat K-16"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>
</VirtualHost>
EOF

# 4. Restart Apache untuk menerapkan konfigurasi
service apache2 restart
```   
Pengujian dilakukan dengan mengakses path `/admin` tanpa kredensial:   
```sh
curl -I http://penny.k16.com/admin
```   
Yang dimana menghasilkan status 401 Unauthorized:   
![auth](/img/Soal12/Screenshot%202026-10-01%20231400.png)   

## Soal 13
Setiap entitas dari luar harus memanggil gerbang dengan nama kanoniknya. Jika ada yang mencoba mengakses IP penny dan domain penny.xxx.com, paksa sistem untuk melakukan redirect secara permanen (status code 301) menuju www.xxx.com. Sebaliknya, jika ada yang mengakses IP abbey dan domain abbey.xxx.com, lakukan redirect sementara (status code 302) menuju static.xxx.com.   
Script untuk node Penny adalah:   
```sh
# Konfigurasi VirtualHost Redirect 301 ke www.k16.com beserta VirtualHost utama
cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
# VirtualHost untuk redirect 301 permanen
<VirtualHost *:80>
    ServerName penny.k16.com
    ServerAlias 192.219.3.2
    Redirect 301 / http://www.k16.com/
</VirtualHost>

# VirtualHost utama www.k16.com
<VirtualHost *:80>
    ServerName www.k16.com

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy balancer://vaultcluster>
        BalancerMember http://192.219.1.4 route=obladi
        BalancerMember http://192.219.1.5 route=desmond
        ProxySet lbmethod=byrequests
    </Proxy>

    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    <Location /admin>
        AuthType Basic
        AuthName "Area Rahasia Sindikat K-16"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>
</VirtualHost>
EOF

# Restart Apache
service apache2 restart
```   
Dan script untuk node Abbey adalah:   
```sh
# Konfigurasi VirtualHost Nginx untuk temporary redirect (302) ke static.k16.com
cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
server {
    listen 80;
    server_name abbey.k16.com 192.219.2.2;

    # Redirect sementara (302) menuju static.k16.com
    return 302 http://static.k16.com$request_uri;
}
EOF

# Terapkan konfigurasi dan restart Nginx
ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/default
service nginx restart
```   
Hasil pengujian redirect status 302 pada Abbey:   
![redirect](/img/Soal13/Screenshot%202026-10-01%20231312.png)   

## Soal 14
Di dalam The Mesh, rekam jejak tidak boleh dipalsukan oleh sistem. Pastikan access log pada setiap server web di area vault maupun area core mencatat alamat IP asli milik client (pengunjung) yang diteruskan oleh gerbang, dan bukan mencatat IP dari Penny ataupun Abbey.   
Script untuk node di area vault (obladi dan desmond) pada Apache:   
```sh
# Tambahkan format log proxy_combined ke konfigurasi Apache
cat << 'EOF' >> /etc/apache2/apache2.conf

LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" proxy_combined
CustomLog ${APACHE_LOG_DIR}/access.log proxy_combined
EOF

service apache2 restart
```   
Script untuk node di area core (oblada dan molly) pada Nginx:   
```sh
# Tambahkan format log proxy_combined ke konfigurasi Nginx
sed -i '/http {/a \    log_format proxy_combined '\''$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'\'';\n    access_log /var/log/nginx/access.log proxy_combined;' /etc/nginx/nginx.conf

service nginx restart
```   
Konfigurasi reverse proxy yang memastikan forwarding header Host dan X-Real-IP:   
![proxy-headers](/img/Soal14/Screenshot%202026-10-01%20231431.png)   

## Soal 15
Rootkit menginstruksikan pembuatan jalur proxy khusus yang berdiri sendiri. Pada penny buat reverse proxy untuk path /eternal yang menyajikan directory /var/www/eternal, dan pastikan path ini dapat mengeksekusi (rendering) file php. Pada abbey, buat jalur /orion yang menyajikan directory /var/www/orion, secara murni statis tanpa perlu rendering php.   
Script untuk node Penny adalah:   
```sh
# 1. Buat direktori dan berkas PHP untuk path /eternal
mkdir -p /var/www/eternal
echo '<?php echo "<h1>Jalur Eternal Penny - PHP Rendered OK</h1>"; ?>' > /var/www/eternal/index.php

# 2. Konfigurasi Nginx untuk menangani jalur /eternal dengan PHP-FPM
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://192.219.1.7;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /eternal {
        alias /var/www/eternal;
        index index.php index.html index.htm;
        try_files $uri $uri/ =404;

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php-fpm.sock;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            include fastcgi_params;
        }
    }
}
EOF

# 3. Reload Nginx
nginx -t && service nginx reload
```   
Dan script untuk node Abbey adalah:   
```sh
# 1. Buat direktori dan berkas HTML untuk path /orion (statis murni)
mkdir -p /var/www/orion
echo "Halaman Orion Abbey - Murni Statis Tanpa PHP" > /var/www/orion/index.html

# 2. Konfigurasi Nginx untuk menyajikan jalur /orion tanpa modul PHP
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location /orion {
        alias /var/www/orion;
        index index.html index.htm;
        try_files $uri $uri/ =404;
    }
}
EOF

# 3. Terapkan dan reload Nginx
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t && service nginx reload
```   
Pengujian dilakukan dari klien delta dengan perintah:   
```sh
# Uji jalur /eternal di Penny
curl -I http://192.219.3.2/eternal/

# Uji jalur /orion di Abbey
curl -I http://192.219.2.2/orion/
```   
Hasil pengujian menunjukkan jalur `/orion` merespon dengan status `200 OK`:   
![orion-eternal](/img/Soal15/Screenshot%202026-10-01%20231451.png)   

## Soal 16
Ketahanan gerbang The Mesh harus diuji untuk menghadapi bombardir permintaan. Salah satu Klien (misal: Alpha) bertugas melakukan stress test benchmark menggunakan ApacheBench. Lakukan 250 requests dengan tingkat konkurensi (concurrencies) 10 untuk masing - masing titik akhir: www.xxx.com dan static.xxx.com. Tampilkan rangkuman hasilnya.   
Script yang dijalankan pada node Alpha adalah:   
```sh
# 1. Pasang paket utilitas ApacheBench
apt update && apt install -y apache2-utils

# 2. Jalankan uji beban pada titik akhir www.k16.com (Penny)
ab -n 250 -c 10 http://www.k16.com/

# 3. Jalankan uji beban pada titik akhir static.k16.com (Abbey)
ab -n 250 -c 10 http://static.k16.com/
```   
Hasil rangkuman benchmark menunjukkan semua 250 requests berhasil diselesaikan tanpa kegagalan (0 failed requests):   
![benchmark](/img/Soal16/Screenshot%202026-10-01%20231607.png)   

## Soal 17
Tambahkan TXT record pada DNS untuk semua klien sayap kiri dan sayap kanan (Alpha, Beta, Gamma, Delta, Epsilon). Jika DNS di-query TXT terhadap nama domain mereka (contoh: alpha.<xxxx>.com), sistem harus mengembalikan teks berupa nama hostname mereka masing-masing (contoh: "alpha").   
Script yang ditambahkan pada node prab adalah:   
```sh
# 1. Tambahkan data TXT Record klien ke dalam berkas zona
cat << 'EOF' >> /etc/bind/zones/db.k16.com

; TXT Records untuk Klien Sayap Kiri & Kanan
alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
EOF

# 2. Naikkan nomor serial SOA di db.k16.com dan restart DNS
sed -i 's/202610010[0-9]/2026100102/g' /etc/bind/zones/db.k16.com
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
Pengujian dilakukan dari klien delta:   
```sh
dig TXT alpha.k16.com +short
dig TXT delta.k16.com +short
```   
Yang dimana hasilnya mengembalikan nama hostname yang sesuai:   
![txt](/img/Soal17/Screenshot%202026-10-01%20231632.png)   

## Soal 18
Ubah A record DNS milik abbey.xxx.com ke alamat IP yang fiktif (ubah secara random namun pastikan format IP valid). Naikkan nilai serial SOA di prab dan pastikan tedd ikut tersinkron. Tetapkan TTL sebesar 15 detik pada record yang relevan tersebut. Verifikasi momen yang terjadi pada tiga fase pencarian: sebelum perubahan terjadi (mengembalikan IP lama), saat perubahan baru saja terjadi dalam jeda 15 detik (masih IP lama karena cache), dan setelah batas waktu TTL habis (berubah ke IP fiktif yang baru).   
Script untuk node prab adalah:   
```sh
# 1. Ubah baris A record abbey dengan TTL 15 detik dan IP pengujian 192.219.2.222
sed -i 's/^abbey.*/abbey 15 IN A 192.219.2.222/g' /etc/bind/zones/db.k16.com

# 2. Naikkan serial SOA ke 2026100103 agar tersinkron ke tedd
sed -i 's/202610010[0-9]/2026100103/g' /etc/bind/zones/db.k16.com
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
Dan script untuk node tedd adalah:   
```sh
# Pastikan data zona terbaru ditarik dari master
service named restart 2>/dev/null || service bind9 restart 2>/dev/null  
```   
Pengujian verifikasi dari klien delta:   
```sh
dig @192.219.1.3 SOA k16.com +short
dig @192.219.1.3 abbey.k16.com +short
```   
Hasilnya menunjukkan serial SOA terbarui dan IP fiktif `192.219.2.222` berhasil diperoleh:   
![ttl](/img/Soal18/Screenshot%202026-10-01%20231654.png)   

## Soal 19
Last? But not least? Buat CNAME record yang melakukan binding dari domain internal outbound.xxx.com menuju domain eksternal http.badssl.com, Lakukan perintah curl ke http://outbound.xxx.com dan pastikan output yang dihasilkan sesuai dengan isi konten di halaman http.badssl.com.   
Script yang ditambahkan pada node prab adalah:   
```sh
# 1. Tambahkan baris CNAME outbound yang mengarah ke domain eksternal badssl
cat << 'EOF' >> /etc/bind/zones/db.k16.com
outbound IN CNAME http.badssl.com.
EOF

# 2. Restart layanan BIND9
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
```   
Pengujian dilakukan dari klien alpha dengan perintah curl:   
```sh
curl http://outbound.k16.com
```   
Hasilnya halaman http.badssl.com berhasil ditampilkan:   
![cname-badssl](/img/Soal19/Screenshot%202026-10-01%20231719.png)   

## Soal 20
Setelah semua penyelesaian selesai, pastikan semua service dan konfigurasi yang telah dikerjakan dari awal tetap berjalan normal dan berstatus autostart saat node di-restart (khusus untuk kasus ini, abaikan konfigurasi nomor 18 dan biarkan koordinat kembali normal).   
Script pada node rootkit:   
```sh
# Pastikan IP forwarding dan NAT iptables tersimpan permanen
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
netfilter-persistent save 2>/dev/null || iptables-save > /etc/iptables.rules
```   
Script pada node prab:   
```sh
# 1. Kembalikan A record abbey ke kondisi normal tanpa TTL khusus
sed -i 's/^abbey.*/abbey IN A 192.219.2.2/g' /etc/bind/zones/db.k16.com

# 2. Aktifkan autostart BIND9 dan restart layanan
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
systemctl enable named 2>/dev/null || update-rc.d named defaults 2>/dev/null || update-rc.d bind9 defaults
```   
Script pada node tedd:   
```sh
# Aktifkan autostart BIND9 dan restart layanan
service named restart 2>/dev/null || service bind9 restart 2>/dev/null
systemctl enable named 2>/dev/null || update-rc.d named defaults 2>/dev/null || update-rc.d bind9 defaults
```   
Script pada node Abbey:   
```sh
# Aktifkan autostart Nginx
service nginx restart
systemctl enable nginx 2>/dev/null || update-rc.d nginx defaults
```   
Script pada node Penny:   
```sh
# Aktifkan autostart Nginx
service nginx restart
systemctl enable nginx 2>/dev/null || update-rc.d nginx defaults
```   
Pengujian autostart menyeluruh dilakukan dari node alpha setelah reboot:   
```sh
echo "=== 1. DNS Abbey (Normal) ===" && dig abbey.k16.com +short && \
echo "=== 2. TXT Record Delta ===" && dig TXT delta.k16.com +short && \
echo "=== 3. Web Gateway www ===" && curl -s -I http://www.k16.com/ | head -n 1 && \
echo "=== 4. Web Gateway static ===" && curl -s -I http://static.k16.com/ | head -n 1 && \
echo "=== 5. Outbound BadSSL ===" && curl -s -I http://outbound.k16.com/ | head -n 1
```   
Hasil pengujian membuktikan seluruh layanan DNS, TXT record, Web Gateway, dan CNAME outbound berhasil menyala secara otomatis dan normal:   
![autostart-test](/img/Soal20/Screenshot%202026-10-01%20231749.png)