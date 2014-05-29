#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

php composer.phar install --prefer-source
cp config.php.dist config.php
mysql -uroot -e 'create database beacon_wallet;'
mysql -uroot --database=beacon_wallet < sql/install.sql
mysql -uroot --database=beacon_wallet < sql/test.sql
