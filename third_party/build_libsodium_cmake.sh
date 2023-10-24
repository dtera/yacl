#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

pkg=libsodium-"$libsodium_ver"
[ -f src/"$pkg".tar.gz ] || curl https://download.libsodium.org/libsodium/releases/"$pkg".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" && cp ../src/libsodium/CMakeLists.txt ./
sed -e 's/@VERSION@/1.0.18/g' \
    -e 's/@SODIUM_LIBRARY_VERSION_MAJOR@/11/g' \
    -e 's/@SODIUM_LIBRARY_VERSION_MINOR@/0/g' \
    -e 's/@SODIUM_LIBRARY_MINIMAL_DEF@//g' \
    src/libsodium/include/sodium/version.h.in > src/libsodium/include/sodium/version.h
mkdir build && cd build || exit

cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8 && make install

cd "$CD" || exit
rm -rf "$pkg"
