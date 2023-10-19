#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build fmt
# [ -d fmt ] || git clone https://github.com/fmtlib/fmt.git
pkg=fmt-"$fmt_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/fmtlib/fmt/archive/refs/tags/"$fmt_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8 && make install
cd "$CD" || exit
rm -rf "$pkg"
