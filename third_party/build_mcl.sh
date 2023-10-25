#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build mcl
# [ -d mcl ] || git clone https://github.com/herumi/mcl.git
pkg=mcl-"$mcl_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/herumi/mcl/archive/refs/tags/v"$mcl_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8 && make install

cd "$CD" || exit
rm -rf "$pkg"
