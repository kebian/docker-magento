# docker-magento

## Dockerfile for Magento Installation

* Links with a mysql container named 'db'
* Links with a memcached container named 'cache'
* Based on Debian Jessie
* nginx
* php5-fpm
* cron configured
* domain.crt and domain.key in /var/www/ssl/
* web site in /var/www/htdocs/
* /var/www/ volume
