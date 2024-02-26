#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

pkg=yacl
mkdir -p tmp/$pkg
cp -R cmake include third_party $pkg CMakeLists.txt tmp/$pkg/
pushd tmp
rm -rf $pkg/third_party/{include,lib,proto-generated,bin,share,src/hash_drbg}
if [[ "$OSTYPE" == "darwin"* ]]; then
  gtar cvf $pkg.tar.gz $pkg
else
  tar cvf $pkg.tar.gz $pkg
fi
rm -f ../$pkg.tar.gz && mv $pkg.tar.gz ..
popd
rm -rf tmp