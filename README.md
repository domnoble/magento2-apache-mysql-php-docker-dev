# magento2-apache-mysql-php-docker-dev"

 docker-compose development stack for magento 2 has been tested on windows and linux

## Apache 2.4.37, PHP 7.1+ & MySQL 5.7+

This stack is suitible for development only, setup with the correct php extensions and apache modules for magento2

### Installation

First create html directory then download latest magento2 release from magento.com or [here on github](https://github.com/magento/magento2/releases) and extract the files to the root of the html directory, the main difference is the magento.com version comes with sample data and vendor dependencies already installed

`mkdir html`

to install dependencies and run the containers:

`docker-compose up -d`

to access the php container to run commands in its shell you can use :

`docker-compose exec php /bin/bash`

the php container is set to have the magento directory as its working directory so you can also run commands like so :

`docker-compose run php php bin/magento`

if you installed the release from github then you will need to run composer for the php dependencies the stable version from magento.com already includes the vendor files so you do not need to run this, you can also run this on the host machine if you have setup php with the correct libraries enabled

`composer install`

you can then install magento2 using the command line like below or GUI if you visit localhost:8085 in the browser.

```
docker-compose run php php bin/magento setup:install \
 --base-url=http://localhost:8085 \
 --db-host=localhost \
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

if you installed magento2 from magento.com and did a GUI install you may want to remove the sample data:

`php bin/magento sampledata:remove`

you may also need to run the following command to setup themes, scripts and css :

`php bin/magento setup:static-content:deploy -f`

if you have a problem with urls not going to the right location :

`php bin/magento indexer:reindex`
