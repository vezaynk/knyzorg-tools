DOMAIN=$1
USER=$2

if [ -z "$DOMAIN" ]; then echo "Please supply domain!
Usage:
	./new-apache-site.sh [domain] [user]
"; exit 1; else echo "Generating Apache2 Configuration for $DOMAIN and www.$DOMAIN"; fi

if [ -z "$USER" ]; then echo "Please supply user name!
Usage:
        ./new-apache-site.sh [domain] [port]
"; exit 1; else echo "Assigning to user $USER"; fi


echo "[+] Create apache conf file"
echo "<VirtualHost *:8080>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin slava@knyz.org
    DocumentRoot /var/www/sites/$DOMAIN
    ErrorLog /home/$USER/$DOMAIN.error.log
    CustomLog /home/$USER/$DOMAIN.access.log combined
    <IfModule mpm_itk_module>
        AssignUserId $USER www-data
    </IfModule>
</VirtualHost>
" > /etc/apache/sites-available/$DOMAIN.conf
echo "[+] Running apache configuration test"
if apachectl configtest 2>/dev/null; then 
	echo "[+] apache configuration passed."; 
else
	echo "[-] apache validation failed. Removing site.";
	rm /etc/apache2/sites-available/$DOMAIN.conf
	exit 1;
fi

echo "[+] Enable site"
ln -s /etc/apache2/sites-available/$DOMAIN.conf /etc/apache2/sites-enabled/

echo "[+] Reload apache2 service"
service apache2 reload
