#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

# build absl
"$CD"/build_absl.sh

# build fmt
"$CD"/build_fmt.sh

# build msgpack
"$CD"/build_msgpack.sh

# build tommath
"$CD"/build_tommath.sh

# build spdlog
#"$CD"/build_spdlog.sh

# build openssl
#"$CD"/build_openssl.sh
