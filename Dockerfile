FROM debian:jessie
MAINTAINER robs@codexsoftware.co.uk

# Using this UID / GID allows local and live file modification of web site
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

RUN apt-get update && apt-get install -y php5-fpm php5-mysql php5-mcrypt php5-curl php5-memcached php5-gd nginx supervisor cron

# Set up web server.
ADD nginx-default-server.conf /etc/nginx/sites-available/default
ADD domain.crt /etc/nginx/conf.d/
ADD domain.key /etc/nginx/conf.d/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install Magento
ADD http://www.magentocommerce.com/downloads/assets/1.9.1.1/magento-1.9.1.1.tar.gz /tmp/
RUN cd /tmp && tar -zxvf magento-1.9.1.1.tar.gz
RUN rm -rf /var/www
RUN mv /tmp/magento /var/www

# Configure Magento
ADD mage-cache.xml /var/www/app/etc/mage-cache.xml
ADD seturl.php /var/www/seturl.php
RUN sed -i "s/<host>localhost/<host>db/g" /var/www/app/etc/config.xml
RUN sed -i "s/<username\/>/<username>user<\/username>/" /var/www/app/etc/config.xml
RUN sed -i "s/<password\/>/<password>password<\/password>/g" /var/www/app/etc/config.xml
RUN sed -i -e  '/<\/config>/{ r /var/www/app/etc/mage-cache.xml' -e 'd}' /var/www/app/etc/local.xml.template
RUN rm /var/www/app/etc/mage-cache.xml

RUN chown -R www-data.www-data /var/www

# Set up cron
ADD crontab /var/spool/cron/crontabs/www-data
RUN chown www-data.crontab /var/spool/cron/crontabs/www-data
RUN chmod 0600 /var/spool/cron/crontabs/www-data


# Configure supervisord
ADD supervisord.conf /etc/
ADD supervisor_conf/* /etc/supervisor/conf.d/

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/bin/supervisord"]