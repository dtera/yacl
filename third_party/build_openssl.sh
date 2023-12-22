#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
WD=$CD
. ./versions.sh
SSL_PREFIX=$([[ "$1" == "" ]] && echo "$CD" || echo "$1")

# build openssl
# [ -d OpenSSL_"$openssl_ver" ] || git clone https://github.com/openssl/openssl.git
#pkg=OpenSSL_"$openssl_ver"
#dir=openssl-OpenSSL_"$openssl_ver"
pkg=openssl-"$openssl_ver"
dir=openssl-openssl-"$openssl_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/openssl/openssl/archive/refs/tags/"$pkg".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && mv "$dir" "$pkg" && cd "$pkg" || exit 0

arch_name=$(arch)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ "$arch_name" == "aarch64"* ]] || [[ "$arch_name" == "arm64"* ]]; then
    # ARM64
    ./Configure enable-rc5 zlib darwin64-arm64-cc no-asm --prefix="$SSL_PREFIX"
  elif [[ "$arch_name" == *"86"* ]] || [[ "$arch_name" == "amd"* ]] || [[ "$arch_name" == *"64"* ]]; then
    # AMD64
    ./Configure enable-rc5 zlib darwin64-x86_64-cc no-asm --prefix="$SSL_PREFIX"
  fi
#elif [[ "$OSTYPE" == "linux"* ]]; then   # not work for posix shell
elif echo "$OSTYPE" | grep -q "linux" || [[ "$OSTYPE" == "" ]]; then
  ./config --prefix="$SSL_PREFIX"
else
  echo "not supported os type: ${OSTYPE}"
  exit 1
fi

make -j8
make install_sw
#make install_ssldirs
if [[ "$SSL_PREFIX" != "$WD" ]]; then
  [ -d "../include/openssl" ] || mv "$SSL_PREFIX/include/openssl" "$WD/include/"
  flag=$([[ -d "$SSL_PREFIX/lib64" ]] && echo "64" || echo "")
  mv "$SSL_PREFIX/lib$flag/libssl."* "$WD/lib/"
  mv "$SSL_PREFIX/lib$flag/libcrypto."* "$WD/lib/"
  rm -rf "$SSL_PREFIX"/lib"$flag"/{cmake,pkgconfig,engines-1.1,engines-3,ossl-modules}
fi

cd "$WD" || exit
rm -rf "$pkg"
