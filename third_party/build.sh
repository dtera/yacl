#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
[ -d src ] || mkdir src
SSL_PREFIX=$([[ "$1" == "" ]] && echo "$CD" || echo "$1")

rm -rf include lib lib64 && mkdir include lib

# build absl
sh "$CD"/build_absl.sh

# build fmt
sh "$CD"/build_fmt.sh &

# build msgpack
sh "$CD"/build_msgpack.sh &

# build tommath
sh "$CD"/build_tommath.sh &

# build spdlog
sh "$CD"/build_spdlog.sh &

# build openssl
sh "$CD"/build_openssl.sh "$SSL_PREFIX" &

# build blake3
sh "$CD"/build_blake3.sh &

# build libsodium
sh "$CD"/build_libsodium_cmake.sh &

# build curve25519
sh "$CD"/build_curve25519.sh &

# build mcl
#sh "$CD"/build_mcl.sh &

# build leveldb
sh "$CD"/build_leveldb.sh &

# build cpu_features
sh "$CD"/build_cpu_features.sh &

# build hash_drbg
sh "$CD"/build_hash_drbg.sh &

# build benchmark
sh "$CD"/build_benchmark.sh &

# build gflags
sh "$CD"/build_gflags.sh &

# build protobuf
sh "$CD"/build_protobuf.sh &

# build ippcp
#sh "$CD"/build_ippcp.sh &

# build brpc
#sh "$CD"/build_brpc.sh &

# build grpc
#sh "$CD"/build_grpc.sh $grpc_ver &

wait
cd "$CD" || exit
if echo "$OSTYPE" | grep -q "linux" || [[ "$OSTYPE" == "" ]]; then
  rm -rf lib64/{cmake,pkgconfig,engines-1.1,engines-3,ossl-modules}
  ([ -d lib ] || mkdir lib) && mv lib64/* lib/
fi
rm -rf lib64 && rm -rf bin/{*.sh,c_rehash} && rm -rf share && rm -rf ssl
rm -rf lib/{cmake,pkgconfig,engines-1.1,engines-3,ossl-modules}