#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build cpu_features
# [ -d cpu_features ] || https://github.com/google/cpu_features.git
pkg=cpu_features-"$cpu_features_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/google/cpu_features/archive/refs/tags/v"$cpu_features_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_TESTING=OFF -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8 && make install

cd "$CD" || exit
rm -rf "$pkg"
