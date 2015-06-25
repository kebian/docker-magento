# docker-magento

## Dockerfile for Magento Installation

* Links with a mysql container named 'db'
* Links with a memcached container named 'cache'
* Based on Debian Jessie
* nginx
* php5-fpm
* cron configured
* Web files in /var/www
* domain.crt and domain.key in /etc/nginx/conf.d for ssl.
