#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build gflags
# [ -d gflags ] || git clone https://github.com/gflags/gflags.git
pkg=gflags-"$gflags_ver"
download_url=https://github.com/gflags/gflags/archive/v"$gflags_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" --build_dir "cmake_build"
