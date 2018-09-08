letsencrypt certonly -d $1 -d www.$1 --preferred-challenges http-01 --http-01-port 9999 --cert-name $1 --standalone
