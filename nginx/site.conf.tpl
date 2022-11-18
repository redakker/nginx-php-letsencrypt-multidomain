server {
    listen 80;
    listen [::]:80;

    index index.php index.html;
    server_name ${domain} www.${domain};
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /www/${domain};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot/${domain};
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    
    index index.php index.html;
    server_name ${domain} www.${domain};
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /www/${domain};

    ssl_certificate /ssl/dummy/${domain}/fullchain.pem;
    ssl_certificate_key /ssl/dummy/${domain}/privkey.pem;

    ssl_dhparam /ssl/ssl-dhparams.pem;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

}