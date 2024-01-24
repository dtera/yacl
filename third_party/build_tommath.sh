#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build libtommath
# [ -d libtommath ] || git clone https://github.com/libtom/libtommath.git
pkg="libtommath-$libtommath_ver"
download_url=https://github.com/libtom/libtommath/archive/"$libtommath_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" -o "-DCMAKE_POSITION_INDEPENDENT_CODE=TRUE" -d false

cp "$pkg"/tommath*.h include/libtommath/
rm -rf "$pkg"
