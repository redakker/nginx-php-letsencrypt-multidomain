# Nginx, Php and Letsencrypt in Docker with virtual hosts

!!! This repo is under construction and testing !!!

This Docker compose was ispired by [evgeniy-khist](https://github.com/evgeniy-khist). The solution uses some parts of his code. More automation has been added and made it more compact (Nginx contains certbot and cron too).

This solution covers Nginx with Php running possibilities for more than one virtual hosts (domains). Each an every domain could have a Let's Encrypt certificate which are retrieved automatically.
You need to fill up one environment (docker.env) file, run the docker-compose wait couple of minutes and you are done. Sounds easy, right? It is.

# Prerequisites
 - system which is running docker engine with docker-compose command
 - public domain name(s) which is/are points to this machine

# Setup
 - download this repo
 - edit the **docker.env** file, add your domain(s) and the related e-mail addresses to it (Necessary for the certificate generation).
 - go tho the root folder of the repo and run: **docker-compose up**
 
 # What does it do?
 - creates a html folder and the simple default html file in the folder for every added domain
 - creates a nginx config file for the domains
 - generate a self-signed certificate first for the domains
 - generate on-the-fly Let's Encrypt certificate for each domain
 - create a cron job for renew the certificates
 
 # F.A.Q
 - what if I want to add a local virtual host
   - You can do that, just create a new config file to the sites folder (anydomainname.com)
   - and create a html folder (anydomainname) manually for your files in a www folder
   
   ```
   #Example:
   server {
    listen 80;
    server_name anydomainname.com;

    location / {
        root /www/anydomainname.com;
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
   }
   ```
   
   
 - what if I want to add a proxy pass to my other docker containers
   - You can do that, just create a new config file to the sites folder     
   
   ```
   #Example:
   server {
    listen 80;
    server_name proxydomain.com;

    location / {
        proxy_pass http://docker_container_name;
    }
   }
   ```
 - what if I want to use certificates for that domain which does the proxy?
   - add your domain to the docker.env file and run the system. It will generate the cert for the domain and creates the config files
   - after that you can edit the config files and put the proxy section to it
   - the config file never will be overwritten later
