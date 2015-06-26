FROM debian:jessie
MAINTAINER robs@codexsoftware.co.uk

# Using this UID / GID allows local and live file modification of web site
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

RUN apt-get update && apt-get install -y php5-fpm php5-mysql php5-mcrypt php5-curl php5-memcached php5-gd nginx supervisor cron git sudo

# Set up web server.
ADD nginx-default-server.conf /etc/nginx/sites-available/default
RUN rm -rf /var/www
RUN mkdir -p /var/www
RUN mkdir -p /var/www/ssl
ADD domain.crt /var/www/ssl/
ADD domain.key /var/www/ssl/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf


# Install Magento
ADD http://www.magentocommerce.com/downloads/assets/1.9.1.1/magento-1.9.1.1.tar.gz /tmp/
RUN cd /tmp && tar -zxvf magento-1.9.1.1.tar.gz
RUN mv /tmp/magento /var/www/htdocs

# Configure Magento
ADD mage-cache.xml /var/www/htdocs/app/etc/mage-cache.xml
ADD seturl.php /var/www/htdocs/seturl.php
RUN sed -i "s/<host>localhost/<host>db/g" /var/www/htdocs/app/etc/config.xml
RUN sed -i "s/<username\/>/<username>user<\/username>/" /var/www/htdocs/app/etc/config.xml
RUN sed -i "s/<password\/>/<password>password<\/password>/g" /var/www/htdocs/app/etc/config.xml
RUN sed -i -e  '/<session_save>{{session_save}}<\/session_save>/{ r /var/www/htdocs/app/etc/mage-cache.xml' -e 'd}' /var/www/htdocs/app/etc/local.xml.template
RUN rm /var/www/htdocs/app/etc/mage-cache.xml

# Enable REDIS in Magento
RUN sed -i "s/<active>false<\/active>/<active>true<\/active>/" /var/www/htdocs/app/etc/modules/Cm_RedisSession.xml

ADD update.sh /var/www/
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

VOLUME ["/var/www/"]

ENTRYPOINT ["/usr/bin/supervisord"]