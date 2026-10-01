# Pastikan data zona terbaru ditarik dari master
service named restart 2>/dev/null || service bind9 restart 2>/dev/null