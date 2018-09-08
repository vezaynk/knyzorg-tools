DOMAIN=$1
PORT=$2

if [ -z "$DOMAIN" ]; then echo "Please supply domain!
Usage:
	./new-nginx-site.sh [domain] [port]
"; exit 1; else echo "Generating NGINX Configuration with SSL certs for
$DOMAIN and www.$DOMAIN"; fi

if [ -z "$PORT" ]; then echo "Please supply port number!
Usage:
        ./new-nginx-site.sh [domain] [port]
"; exit 1; else echo "Proxying service from port $PORT"; fi

echo "[+] Generate new certs"
./getcert.sh $DOMAIN

if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
    echo "[-] It appears letsencrypt failed to generate a cert. Exiting."
    exit 1
fi

echo "[+] Create nginx conf file"
echo "server {
	listen 80;
	listen [::]:80;
	listen 443 ssl;
	listen [::]:443 ssl;
	server_name $DOMAIN www.$DOMAIN;
	add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\" always;
	ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
	location /.well-known {
		allow all;
		proxy_pass http://localhost:9999/.well-known;
	}
	location / {
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$remote_addr;
		proxy_set_header Host \$host;
		proxy_pass http://localhost:$PORT;
	}
}
" > /etc/nginx/sites-available/$DOMAIN.conf
echo "[+] Running nginx configuration test"
if nginx -t 2>/dev/null; then 
	echo "[+] NGINX configuration passed."; 
else
	echo "[-] NGINX validation failed. Removing site.";
	rm /etc/nginx/sites-available/$DOMAIN.conf
	exit 1;
fi

echo "[+] Enable site"
ln -s /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/

echo "[+] Reload NGINX service"
service nginx reload
