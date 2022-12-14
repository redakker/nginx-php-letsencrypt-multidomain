#!/bin/sh

set -e

if [ -z "$DOMAINS" ]; then
  echo "DOMAINS environment variable is not set"
  exit 1;
fi

use_dummy_certificate() {
  if grep -q "/etc/letsencrypt/live/$1" "etc/nginx/conf.d/$1.conf"; then
    echo "Switching Nginx to use dummy certificate for $1"
    sed -i "s|/etc/letsencrypt/live/$1|/ssl/dummy/$1|g" "etc/nginx/conf.d/$1.conf"
  fi
}

use_lets_encrypt_certificate() {
  if grep -q "/ssl/dummy/$1" "etc/nginx/conf.d/$1.conf"; then
    echo "Switching Nginx to use Let's Encrypt certificate for $1"
    sed -i "s|/ssl/dummy/$1|/etc/letsencrypt/live/$1|g" "etc/nginx/conf.d/$1.conf"
  fi
}

reload_nginx() {
  echo "Reloading Nginx configuration"
  nginx -s reload
}

wait_for_lets_encrypt() {
  until [ -d "/etc/letsencrypt/live/$1" ]; do
    echo "Waiting for Let's Encrypt certificates for $1"
    sleep 5s & wait ${!}
  done
  use_lets_encrypt_certificate "$1"
  reload_nginx
}

if [ ! -f /ssl/ssl-dhparams.pem ]; then
  mkdir -p "/ssl"
  openssl dhparam -out /ssl/ssl-dhparams.pem 2048
fi

domains_fixed=$(echo "$DOMAINS" | tr -d \")
for domain in $domains_fixed; do
  echo "Checking configuration for $domain"

  if [ ! -f "/etc/nginx/conf.d/$domain.conf" ]; then
    echo "Creating Nginx configuration file /etc/nginx/conf.d/$domain.conf"
    sed "s/\${domain}/$domain/g" /templates/site.conf.tpl > "/etc/nginx/conf.d/$domain.conf"
  fi

  
  if [ ! -d "/www/$domain" ]; then
    echo "Creating Nginx html folder for domain $domain"
    mkdir -p /www/$domain
    touch /www/$domain/index.html
    echo "Default page of $domain" > /www/$domain/index.html
  fi


  if [ ! -f "/ssl/dummy/$domain/fullchain.pem" ]; then
    echo "Generating dummy ceritificate for $domain"
    mkdir -p "/ssl/dummy/$domain"
    printf "[dn]\nCN=${domain}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$domain, DNS:www.$domain\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > openssl.cnf
    openssl req -x509 -out "/ssl/dummy/$domain/fullchain.pem" -keyout "/ssl/dummy/$domain/privkey.pem" \
      -newkey rsa:2048 -nodes -sha256 \
      -subj "/CN=${domain}" -extensions EXT -config openssl.cnf
    rm -f openssl.cnf
  fi

  if [ ! -d "/etc/letsencrypt/live/$domain" ]; then
     use_dummy_certificate "$domain"
     wait_for_lets_encrypt "$domain" &
  else
     use_lets_encrypt_certificate "$domain"
  fi
done

/scripts/certbot.sh &

exec nginx -g "daemon off;"
