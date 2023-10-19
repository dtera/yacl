#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

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
sh "$CD"/build_libsodium.sh

# build curve25519
sh "$CD"/build_curve25519.sh

# build brpc
#sh "$CD"/build_brpc.sh

# build grpc
#sh "$CD"/build_grpc.sh $grpc_ver

cd "$CD" || exit
rm -rf lib/cmake && rm -rf lib/pkgconfig && rm -rf lib/engines-1.1