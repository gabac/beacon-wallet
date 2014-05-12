#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

#brew update
#brew tap homebrew/dupes
#brew tap homebrew/versions
#brew tap homebrew/homebrew-php
#brew install php55
curl -sS https://getcomposer.org/installer | php
composer self-update
