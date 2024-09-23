#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cmake -B /libcreate/build -S /libcreate -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS='-Werror'
cmake --build /libcreate/build --config Release
ctest -C Release --output-on-failure
cpack --build /libcreate/build -G DEB

debs=(/libcreate/_packages/*.deb)
cp "${debs[0]}" /tmp/libcreate.deb
dpkg-deb -R /tmp/libcreate.deb /tmp/libcreate
tree /tmp/libcreate