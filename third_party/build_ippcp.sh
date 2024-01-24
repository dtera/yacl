#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh
[[ "$(arch)" == "x86_64" ]] || exit 0

# build ipp-crypto
# [ -d ipp-crypto ] || git clone https://github.com/intel/ipp-crypto.git
pkg=ipp-crypto-ippcp_"$ippcp_ver"
download_url=https://github.com/intel/ipp-crypto/archive/refs/tags/ippcp_"$ippcp_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" \
-o "-DARCH=intel64 -DOPENSSL_INCLUDE_DIR=$CD/include -DOPENSSL_LIBRARIES=$CD/lib -DOPENSSL_ROOT_DIR=$CD"
