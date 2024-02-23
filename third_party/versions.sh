#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

absl_ver=20240116.1
fmt_ver=10.2.1
msgpack_ver=6.1.0
openssl_ver=3.0.12
spdlog_ver=1.13.0
libtommath_ver=8314bde5e5c8e5d9331460130a9d1066e324f091
blake3_ver=1.5.0
libsodium_ver=1.0.18
curve25519_ver=2fe66b65ea1acb788024f40a3373b8b3e6f4bbb2
mcl_ver=1.86.0
leveldb_ver=1.23
brpc_ver=1.8.0
grpc_ver=1.54.0
cpu_features_ver=0.9.0
ippcp_ver=2021.8
hash_drbg_ver=2411fa9d0de81c69dce2a48555c30298253db15d
benchmark_ver=1.8.3
gflags_ver=2.2.2
protobuf_ver=4.25.2
