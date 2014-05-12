#!/usr/bin/env sh

# abort script on failure
set -e -x

cd `dirname $0`/../..

xctool -workspace beacon-wallet-iphone.xcworkspace -scheme beacon-wallet-iphone -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
xctool test -workspace beacon-wallet-iphone.xcworkspace -scheme beacon-wallet-iphone -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
