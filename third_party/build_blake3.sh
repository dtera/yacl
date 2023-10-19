#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build BLAKE3
# [ -d BLAKE3 ] || git clone https://github.com/BLAKE3-team/BLAKE3.git
pkg=BLAKE3-"$blake3_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/"$blake3_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit
# shellcheck disable=SC2044
for path in $(find c -name "*.h"); do
  #head_file=${path##*/}
  head_path=${path%/*}
  head_save_path="$CD"/include/$head_path
  mkdir -p "$head_save_path" && cp "$path" "$head_save_path"
done

cd c && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8

cp -R "$CD"/$pkg/c/build/libblake3.* "$CD"/lib/ && rm -rf "$CD"/lib/libblake3.pc

cd "$CD" || exit
rm -rf "$pkg"
