#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build benchmark
# [ -d benchmark ] || git clone https://github.com/google/benchmark.git
pkg=benchmark-"$benchmark_ver"
download_url=https://github.com/google/benchmark/archive/refs/tags/v"$benchmark_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" -o "-DBENCHMARK_DOWNLOAD_DEPENDENCIES=on"
