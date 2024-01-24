#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build leveldb
# [ -d leveldb ] || git clone https://github.com/google/leveldb.git
pkg=leveldb-"$leveldb_ver"
download_url=https://github.com/google/leveldb/archive/refs/tags/"$leveldb_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" -o "-DLEVELDB_BUILD_TESTS=OFF -DLEVELDB_BUILD_BENCHMARKS=OFF"
