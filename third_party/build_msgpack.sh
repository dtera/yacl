#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build msgpack
# [ -d msgpack-c ] || git clone https://github.com/msgpack/msgpack-c.git
pkg=msgpack-c-cpp-"$msgpack_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/msgpack/msgpack-c/archive/refs/tags/cpp-"$msgpack_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cp -R "$pkg"/include/* ./include/
cd "$CD" || exit
rm -rf "$pkg"
