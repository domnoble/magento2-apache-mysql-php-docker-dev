
#!/usr/bin/env bash
#
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
MYSQL_ROOT_PASSWORD="sqlStrongPassword"
#
sudo yum -y update kernel
sudo yum -y install kernel-devel kernel-headers dkms gcc gcc-c++
sudo yum -y install epel-release yum-utils expect policycoreutils-python selinux-policy-minimum
sudo yum -y install mailx git libmcrypt-devel openssl-devel wget nano curl nodejs
#
# MySQL server 5.6 and MySQL cli interface install, you can set the root database password here, the default password is "rootpass".
# todo : add options for more database versions like mariaDB, SQLite ect and add variable for password from vagrant if possible
#
#
echo -e "${BLUE}Starting MariaDB Install${NC}"
sudo yum -y update
sudo yum -y install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
sudo yum repolist enabled | grep "mysql.*-community.*"
sudo yum -y install mysql-community-server
#
systemctl enable mysqld
systemctl start mysqld
#
sudo mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root'"
# Make our changes take effect
sudo mysql -e "FLUSH PRIVILEGES"
#
# Apache2 installation, this could also be changed to nginx
# todo : add switch between nginx and apache
#
echo -e "${BLUE}Starting Apache2 Install${NC}"
sudo yum -y install httpd
#
sudo systemctl enable httpd
sudo systemctl start httpd
#
echo -e "${BLUE}Apache should be version >= 2.4, the current version is :${NC}"
rpm -q httpd
#
# Installation of PHPFPM with PHP7.0, PHP5.6 and all the magento dependencies using the recommended ondrej/php PPA.
#
echo -e "${BLUE}Adding IUS(Inline for Upstream Stable) for PHP7.1 binaries${NC}"
sudo yum install -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm
sudo yum -y update
sudo yum -y install php71u php71u-pdo php71u-mysqlnd php71u-opcache php71u-xml php71u-mcrypt php71u-gd php71u-devel php71u-mysql php71u-intl php71u-mbstring php71u-bcmath php71u-json php71u-iconv php71u-soap
#
#
echo "${BLUE}PHP version should be version >= 7.1, the current version is :${NC}"
php -v
#
echo "${BLUE}PHP extensions:${NC}"
php -me
#
#
if ! [ -L /var/www ];
then
  rm -rf /var/www/html
  ln -fs /srv/html /var/www/html
fi
#
sudo setenforce 0
sudo sed -i 's_SELINUX=enforcing_SELINUX=disabled_' /etc/selinux/config
#
echo -e "${BLUE}Configuring Apache${NC}"
#
sudo rm /etc/httpd/conf/httpd.conf
sudo cp /srv/conf/httpd.conf /etc/httpd/conf/
#
sudo apachectl restart
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
    echo -e "${BLUE}Creating DB and DB user${NC}"
    echo "CREATE USER 'mageuser'@'localhost' IDENTIFIED BY 'magepass'" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "CREATE DATABASE magento" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "GRANT ALL ON magento.* TO 'mageuser'@'localhost'" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "flush privileges" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    touch /var/log/databasesetup
fi
export PATH=$PATH:/var/www/html/bin
