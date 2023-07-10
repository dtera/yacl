#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

# build msgpack
# [ -d msgpack-c ] || git clone https://github.com/msgpack/msgpack-c.git
pkg=msgpack-c-cpp-3.3.0
rm -rf "$pkg" && tar xvf "$pkg".tar.gz && cp -R "$pkg"/include/* ./include/
cd "$CD" || exit
rm -rf "$pkg"
