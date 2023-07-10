#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

# build openssl
# [ -d OpenSSL_1_1_1m ] || wget https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1m.tar.gz
pkg=openssl-1.1.1m
rm -rf "$pkg" && tar xvf "$pkg".tar.gz && cd "$pkg" || exit 0

arch_name=$(arch)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ "$arch_name" == "aarch64"* ]] || [[ "$arch_name" == "arm64"* ]]; then
    # ARM64
    ./Configure enable-rc5 zlib darwin64-arm64-cc no-asm --prefix="$CD/"
  elif [[ "$arch_name" == *"86"* ]] || [[ "$arch_name" == "amd"* ]] || [[ "$arch_name" == *"64"* ]]; then
    # AMD64
    ./Configure enable-rc5 zlib darwin64-x86_64-cc no-asm --prefix="$CD/"
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  ./config --prefix="$CD/"
else
  echo "not supported os type: ${OSTYPE}"
  exit 1
fi

make -j4
make install_sw
make install_ssldirs

cd "$CD" || exit
rm -rf "$pkg"
