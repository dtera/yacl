#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build msgpack
# [ -d msgpack-c ] || git clone https://github.com/msgpack/msgpack-c.git
pkg=msgpack-c-cpp-"$msgpack_ver"
download_url=https://github.com/msgpack/msgpack-c/archive/refs/tags/cpp-"$msgpack_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" --out_only_hdr true
