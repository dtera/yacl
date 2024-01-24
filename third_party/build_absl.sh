#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build abseil-cpp
# [ -d abseil-cpp ] || git clone https://github.com/abseil/abseil-cpp.git
pkg=abseil-cpp-"$absl_ver"
download_url=https://github.com/abseil/abseil-cpp/archive/refs/tags/"$absl_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" -o "-DBUILD_SHARED_LIBS=ON -DABSL_PROPAGATE_CXX_STD=ON" \
-t "strings symbolize stacktrace"
