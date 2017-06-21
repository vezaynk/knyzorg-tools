#!/bin/bash -       
#title           :secureproxy.sh
#description     :Generates SSL certs for nginx automatically and 
proxies it to port 80 and 443.
#author		 :knyzorg
#date            :1498084333
#version         :0.1    
#usage		 :bash secureproxy.sh
#notes           :Assumes availability of nginx in /etc/nginx/, the 
Debian-like environment (Easy to configure for RHEL) and certbot.
#bash_version    :4.4.12
#==============================================================================

DOMAIN=$1
PORT=$2

if [ -z "$DOMAIN" ]; then echo "Please supply domain!
Usage:
	secureproxy.sh [domain] [port]
"; exit 1; else echo "Generating NGINX Configuration with SSL certs for 
$DOMAIN and www.$DOMAIN"; fi

if [ -z "$PORT" ]; then echo "Please supply port number!
Usage:
        secureproxy.sh [domain] [port]
"; exit 1; else echo "Proxying service from port $PORT"; fi

echo "[+] Stop NGINX service"
service nginx stop>/dev/null
echo "[+] Generate new certs"
certbot certonly --standalone -d "$DOMAIN" -d "www.$DOMAIN"
echo "[+] Create non-ssl conf file"
echo "
server {
        listen 80;
        listen [::]:80;
        server_name $DOMAIN www.$DOMAIN;
        location ~ /.well-known {
                allow all;
        }
        location / {
            proxy_pass http://localhost:$PORT;
        }
}
" > /etc/nginx/sites-available/$DOMAIN.conf
echo "[+] Create ssl conf file"
echo "
server {
        listen 443;
        listen [::]:443;
        server_name $DOMAIN www.$DOMAIN;
        ssl on;
        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
        location ~ /.well-known {
                allow all;
        }
        location / {
            proxy_pass http://localhost:$PORT;
	}
}
" > /etc/nginx/sites-available/ssl.$DOMAIN.conf
echo "[+] Enable configuration"
ln -s /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/ssl.$DOMAIN.conf 
/etc/nginx/sites-enabled/

echo "[+] Start NGINX service"
service nginx start
