#!/usr/bin/env sh

# abort script on failure
set -e -x

cd `dirname $0`/../..

pod install
