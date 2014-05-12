#!/usr/bin/env sh

# abort script on failure
set -e -x

# change to working dir
cd `dirname $0`/../..

xctool -workspace beacon-wallet-ipad.xcworkspace -scheme beacon-wallet-ipad -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
xctool test -workspace beacon-wallet-ipad.xcworkspace -scheme beacon-wallet-ipad -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
