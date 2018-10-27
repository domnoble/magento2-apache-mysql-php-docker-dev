# vagrant-centos7-magento2

Vagrant CentOS7 based development box for magento 2

## Apache 2.4.27+ (httpd24 rh scl) & PHP 7.1+ (php71u ius) & MySQL 5.7+

This development machine uses the more up to date redhat software collections httpd24 for http2 testing, as opposed to the usual httpd(Apache 2.4.6) that is included in the default centos repository, it also uses php from Inline with Upstream Stable community project

### Installation

First create html directory then download latest magento2 release from magento.com or [here on github](https://github.com/magento/magento2/releases) and extract the files to the root of the html directory, the main difference is the magento.com version comes with sample data and vendor dependencies already installed

`mkdir html`

to install dependencies and run the vagrant vm run the following two commands:

`vagrant plugin install vagrant-vbguest`

`vagrant up`

If you download with sample data from magento.com a quick fix for the installer failing you can set session save path in app/etc/env.php, (will still hang on 66% when installing SampleData successfully):
```
'session' => [
  'save' => 'files',
  'save_path' => '/tmp',
],
```

login to the guest vm via ssh :

`vagrant ssh`

navigate to the magento2 directory :

`cd /srv/html`

if you installed the release from github then you will need to run composer for the php dependencies the stable version from magento.com already includes the vendor files so you do not need to run this, you can also run this on the host machine if you have setup php with the correct libraries enabled

`composer install`

you can then install magento2 using the command line like below or GUI if you visit localhost:8085 in the browser.

```
php bin/magento setup:install \
 --base-url=http://localhost:8085 \
 --db-host=localhost \
--db-name=magento \
--db-user=mageuser \
--db-password=magepass \
--backend-frontname=admin \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@example.com \
--admin-user=admin \
--admin-password=AdminPass \
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
