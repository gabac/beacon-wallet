#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

pod install
