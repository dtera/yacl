#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
[ -d src ] || mkdir src
rm -rf include/* lib/* && mkdir include lib

# build absl
sh "$CD"/build_absl.sh

# build fmt
sh "$CD"/build_fmt.sh

# build msgpack
sh "$CD"/build_msgpack.sh

# build tommath
sh "$CD"/build_tommath.sh

# build spdlog
sh "$CD"/build_spdlog.sh

# build openssl
sh "$CD"/build_openssl.sh

# build blake3
sh "$CD"/build_blake3.sh

# build libsodium
sh "$CD"/build_libsodium_cmake.sh

# build curve25519
sh "$CD"/build_curve25519.sh

# build mcl
sh "$CD"/build_mcl.sh

# build leveldb
sh "$CD"/build_leveldb.sh

# build brpc
#sh "$CD"/build_brpc.sh

# build grpc
#sh "$CD"/build_grpc.sh $grpc_ver

cd "$CD" || exit
rm -rf bin && rm -rf share && rm -rf ssl && rm -rf lib/cmake && rm -rf lib/pkgconfig && rm -rf lib/engines-1.1