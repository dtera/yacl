#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build hash_drbg
# [ -d hash_drbg ] || git clone https://github.com/greendow/Hash-DRBG.git
pkg=Hash-DRBG-"$hash_drbg_ver"
[ -d src/hash_drbg ] || mkdir src/hash_drbg
[ -f src/"$pkg".tar.gz ] || curl https://github.com/greendow/Hash-DRBG/archive/"$hash_drbg_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit
cp -R hash_drbg.c ../src/hash_drbg/
cp -R hash_drbg.h hash_drbg_error_codes.h ../include/

cd "$CD" || exit
rm -rf "$pkg"

cd ..
rm -rf build && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 ..
make -j8 hash_drbg
cp -R libhash_drbg* ../third_party/lib/
cd ..
