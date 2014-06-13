#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

brew update
brew install mysql
mysql.server start

echo 'date.timezone = "Europe/Zurich"' >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini
