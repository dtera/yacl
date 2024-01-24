#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build cpu_features
# [ -d cpu_features ] || https://github.com/google/cpu_features.git
pkg=cpu_features-"$cpu_features_ver"
download_url=https://github.com/google/cpu_features/archive/refs/tags/v"$cpu_features_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" \
-o "-DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_TESTING=OFF -DCMAKE_INSTALL_LIBDIR=lib"
