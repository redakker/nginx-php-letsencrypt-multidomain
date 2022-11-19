FROM nginx:stable

# Inspiration:
# https://hub.docker.com/r/gaafar/cron/

# Install cron, certbot, bash, plus any other dependencies

RUN apt-get update \
    && apt-get install -y cron bash wget certbot openssl netcat \
    && apt-get update -y \
    && mkdir -p /scripts /templates

COPY site.conf.tpl /templates
COPY *.sh /scripts/


RUN chmod +x /scripts/*.sh




# This installs a Crontab entry which 
# runs "certbot renew" on several days a week at 03:22 AM

#RUN echo "22 03 * * 2,7 root /scripts/*.sh" >/etc/cron.d/certbot-renew

# Run both nginx and cron together
# CMD [ "sh", "-c", "cron && nginx -g 'daemon off;'" ]
CMD ["/scripts/nginx.sh"]