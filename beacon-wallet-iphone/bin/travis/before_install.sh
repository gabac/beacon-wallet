#!/usr/bin/env sh

# abort script on failure
set -e

cd `dirname $0`/../..

brew unlink xctool
brew update
brew install xctool
export LANG=en_US.UTF-8
gem install cocoapods -v '0.32.1'
