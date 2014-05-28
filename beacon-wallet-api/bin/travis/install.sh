#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

php composer.phar install --prefer-source
cp config.php.travis config.php
mysql -e 'create database beacon_wallet;'
mysql --database=beacon_wallet < sql/install.sql
mysql --database=beacon_wallet < sql/test.sql
