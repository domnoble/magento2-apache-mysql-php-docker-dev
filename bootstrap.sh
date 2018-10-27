
#!/usr/bin/env bash
#
RED='\033[0;31m'
GREEN='\033[0;34m'
NC='\033[0m'
MYSQL_ROOT_PASSWORD="sqlStrongPassword"
#
sudo yum -y update kernel
sudo yum -y install kernel-devel kernel-headers dkms gcc gcc-c++ bash
sudo yum -y install epel-release yum-utils expect policycoreutils-python selinux-policy-minimum
sudo yum -y install mailx git libmcrypt-devel openssl-devel wget nano curl nodejs
#
echo -e "${GREEN}Adding Redhat SCL for available versions of PHP, MySQL and Apache${NC}"
sudo yum install -y centos-release-scl
sudo yum -y update
#
# MySQL server install
#
echo -e "${GREEN}Starting MySQL Install${NC}"
sudo yum -y update
sudo yum -y install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
sudo yum repolist enabled | grep "mysql.*-community.*"
sudo yum -y install mysql-community-server
#
systemctl enable mysqld
systemctl start mysqld
#
sudo mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root'"
#
sudo mysql -e "FLUSH PRIVILEGES"
#
echo -e "${BLUE}Adding IUS(Inline for Upstream Stable) for PHP7.1 binaries${NC}"
sudo yum install -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm
sudo yum -y update
#
# Apache2.4 installation
#
echo -e "${GREEN}Starting Apache2.4 Install${NC}"
sudo yum -y install httpd24 httpd24-httpd httpd24-httpd-devel httpd24-mod_ssl httpd24-curl httpd24-build httpd24-httpd-tools httpd24-libcurl httpd24-libnghttp2 httpd24-libnghttp2-devel httpd24-mod_ssl httpd24-mod_session httpd24-nghttp2
#
scl enable httpd24 bash
sudo cp /srv/conf/enablehttpd24.sh /etc/profile.d/
#
sudo systemctl enable httpd24-httpd
sudo systemctl start httpd24-httpd
#
echo -e "${GREEN}Apache should be version >= 2.4, the current version is :${NC}"
sudo httpd -V
#
# PHP7.1 Installation
#
sudo yum -y install php71u php71u-pdo php71u-mysqlnd php71u-opcache php71u-xml php71u-mcrypt php71u-gd php71u-devel php71u-mysql php71u-intl php71u-mbstring php71u-bcmath php71u-json php71u-iconv php71u-soap php71u-fpm-httpd
#
echo "${GREEN}PHP version should be version >= 7.1, the current version is :${NC}"
php -v
#
echo "${GREEN}PHP extensions:${NC}"
php -me
#
#
if ! [ -L /opt/rh/httpd24/root/var/www ];
then
  rm -rf /opt/rh/httpd24/root/var/www/html
  ln -fs /srv/html /opt/rh/httpd24/root/var/www/html
fi
#
sudo setenforce 0
sudo sed -i 's_SELINUX=enforcing_SELINUX=disabled_' /etc/selinux/config
#
echo -e "${GREEN}Configuring Apache & PHP${NC}"
#
sudo rm /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf
sudo cp /srv/conf/httpd.conf /opt/rh/httpd24/root/etc/httpd/conf/
sudo cp /srv/conf/vhost.conf /opt/rh/httpd24/root/etc/httpd/conf.d/
sudo rm /etc/php.ini
sudo cp /srv/conf/php.ini /etc/php.ini
#
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl restart httpd24-httpd
#
# Installation of composer
#
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer
#
# Checks if database is already setup if /var/log/databasesetup doesn't exist it will set up a database and database user
# todo : add variable for db_name, username and password carry variable from initial root password setup
#
if [ ! -f /var/log/databasesetup ];
then
    echo -e "${GREEN}Creating DB and DB user${NC}"
    echo "CREATE USER 'mageuser'@'localhost' IDENTIFIED BY 'magepass'" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "CREATE DATABASE magento" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "GRANT ALL ON magento.* TO 'mageuser'@'localhost'" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "flush privileges" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    touch /var/log/databasesetup
fi
export PATH=$PATH:/srv/html/bin
