# magento2-apache-mysql-php-docker-dev

 docker-compose development stack for magento 2 has been tested on windows and linux

## Apache >2.4.37, PHP >7.1 & MySQL >5.7

This stack is suitible for development only, setup with the correct php extensions and apache modules for magento2, with http2, using fastcgi mod_proxy for connecting php and apache, also with redis and solr

### Installation

clone this repository into a project directory of your choice and move into directory

`git clone https://github.com/domnoble/magento2-apache-mysql-php-docker-dev magento2 && cd magento2`

clone magento2 from [here on github](https://github.com/magento/magento2/releases) and put the files in the html directory:

`git clone https://github.com/magento/magento2.git html`

optionally if you need to use the sample data you will need to clone that repository also into the sample-data directory :

`git clone https://github.com/magento/magento2-sample-data.git sample-data`

if you want to customise the database password or user now would be the point, you can do that by editing the .env file:

```
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=magento
MYSQL_USER=mageuser
MYSQL_PASS=magepass1234
```

to install dependencies and run the containers:

`docker-compose up -d`

to access the php container to run commands in its shell you can use :

`docker-compose exec php /bin/bash`

You will need to install the PHP project dependencies using composer, run inside php container shell :

`composer install`

you can then install magento2 using the shell like below or GUI if you visit localhost:8087 in the browser.

```
php bin/magento setup:install \
--base-url=http://localhost:8087 \
--db-host=db:3306 \
--db-name=magento \
--db-user=mageuser \
--db-password=magepass1234 \
--backend-frontname=admin \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@example.com \
--admin-user=admin \
--admin-password=AdminPass1234 \
--language=en_GB \
--currency=GBP \
--timezone=Europe/London \
--use-rewrites=1
```



you can set magento to development mode with

`php bin/magento deploy:mode:set developer`

if you want to install sample data you need to set the symbolic links to the sample data directory

`php -f /usr/local/apache2/m2-sd/dev/tools/build-sample-data.php -- --ce-source="/usr/local/apache2/htdocs/"`

and upgrade magento to reflect the changes

`php bin/magento setup:upgrade`

you can clear magento cache using :

`php bin/magento cache:clear`

if you dont set development mode you may also need to deploy static content :

`php bin/magento setup:static-content:deploy -f`

if you have a problem with urls not resolving and can't login :

`php bin/magento indexer:reindex`

