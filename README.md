# vagrant-centos7-magento2

First create html directory then download latest magento2 release from magento.com or [here on github](https://github.com/magento/magento2/releases) and extract the files to the root of the html directory

`mkdir html`

to install dependencies and run the vagrant vm run the following two commands:

`vagrant plugin install vagrant-vbguest`

`vagrant up`

If you download with sample data from magento.com a quick fix for the installer failing you can set session save path in app/etc/env.php, (will still hang on 66% when installing SampleData successfully):
```
array (
  'save' => 'files',
  'save_path' => '/tmp',
),
```

to remove SampleData use the folling 3 commands :

`vagrant ssh`

`cd /srv/html`

`php bin/magento sampledata:remove`

if you installed the release from github then you will need to run composer for the php dependencies, you can also run this on the host machine if you have setup php with the correct libraries enabled

`composer install`

you can then install magento using the command line

```
php bin/magento setup:install \
 --base-url=http://localhost \
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

you may also need to run:

`php bin/magento setup:static-content:deploy`

`php bin/magento indexer:reindex`
