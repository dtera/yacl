#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

# build abseil-cpp
# [ -d abseil-cpp ] || git clone https://github.com/abseil/abseil-cpp.git
pkg=abseil-cpp
rm -rf "$pkg" && tar xvf "$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DABSL_PROPAGATE_CXX_STD=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
#cmake --build . --target strings symbolize stacktrace
make -j8 strings symbolize stacktrace && make install
cd "$CD" || exit
#for libs in "$CD"/build/libs/libabsl_*; do
#  [[ "$libs" =~ "strings" ]] || [[ "$libs" =~ "symbolize" ]] || [[ "$libs" =~ "stacktrace" ]] || rm -f "$libs"
#done
rm -rf "$pkg"
