#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

absl_ver=20230125.3
fmt_ver=10.0.0
openssl_ver=1_1_1v
spdlog_ver=1.12.0
libtommath_ver=7f96509df1a6b44867bbda56bbf2cb92524be8ef
blake3_ver=1.4.1
libsodium_ver=1.0.18
brpc_ver=1.6.0
grpc_ver=1.54.0
curve25519_ver=2fe66b65ea1acb788024f40a3373b8b3e6f4bbb2