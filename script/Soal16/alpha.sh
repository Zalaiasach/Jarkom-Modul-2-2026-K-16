# 1. Pasang paket utilitas ApacheBench
apt update && apt install -y apache2-utils

# 2. Jalankan uji beban pada titik akhir www.k16.com (Penny)
ab -n 250 -c 10 http://www.k16.com/

# 3. Jalankan uji beban pada titik akhir static.k16.com (Abbey)
ab -n 250 -c 10 http://static.k16.com/