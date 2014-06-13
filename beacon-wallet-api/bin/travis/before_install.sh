#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

brew update
brew install mysql
mysql.server start

php -i
sudo cp /etc/php.ini.default /etc/php.ini
sudo chmod u+w /etc/php.ini
echo 'date.timezone = "Europe/Zurich"' >> /etc/php.ini
