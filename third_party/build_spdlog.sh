#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

# build spdlog
# [ -d spdlog ] || git clone https://github.com/gabime/spdlog.git
pkg=spdlog-1.10.0
rm -rf "$pkg" && tar xvf "$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8 && make install
cd "$CD" || exit
rm -rf "$pkg"
