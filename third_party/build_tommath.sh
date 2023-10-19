#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build libtommath
# [ -d libtommath ] || git clone https://github.com/libtom/libtommath.git
pkg=libtommath-"$libtommath_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/libtom/libtommath/archive/"$libtommath_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8 && make install
cd "$CD" || exit
cp "$pkg"/tommath*.h include/libtommath/
rm -rf "$pkg"
