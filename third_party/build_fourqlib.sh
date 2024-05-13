#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build FourQlib
# [ -d FourQlib ] || git clone https://github.com/microsoft/FourQlib.git
# shellcheck disable=SC2154

pkg=fourqlib-"$fourqlib_ver"
download_url=https://github.com/microsoft/FourQlib/archive/"$fourqlib_ver".tar.gz
[ -f src/"$pkg".tar.gz ] || curl "$download_url" -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit
#cp "$CD/../bazel/patches/FourQlib.patch" ./
#patch -p1 -i FourQlib.patch

cd "$CD/$pkg/FourQ_64bit_and_portable" || exit
# shellcheck disable=SC2044
for path in $(find . -name "*.h"); do
  #head_file=${path##*/}
  head_path=${path%/*}
  head_save_path="$CD"/include/$head_path
  mkdir -p "$head_save_path" && cp "$path" "$head_save_path"
done

make ARCH=x64

cd "$CD" || exit
rm -rf "$pkg"