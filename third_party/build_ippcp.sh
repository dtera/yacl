#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh
[[ "$(arch)" == "x86_64" ]] || exit 0

# build ipp-crypto
# [ -d ipp-crypto ] || git clone https://github.com/intel/ipp-crypto.git
pkg=ipp-crypto-ippcp_"$ippcp_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/intel/ipp-crypto/archive/refs/tags/ippcp_"$ippcp_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" && mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DARCH=intel64 -DOPENSSL_INCLUDE_DIR="$CD/include" -DOPENSSL_LIBRARIES="$CD/lib" -DOPENSSL_ROOT_DIR="$CD" -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD" ..
make -j8 && make install
cd "$CD" || exit
rm -rf "$pkg"
