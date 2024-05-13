#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build lib25519
# [ -d lib25519 ] || git clone https://github.com/crypto-gh/lib25519.git
# shellcheck disable=SC2154

pkg=lib25519-"$lib25519_ver"
download_url=https://lib25519.cr.yp.to/lib25519-"$lib25519_ver".tar.gz
[ -f src/"$pkg".tar.gz ] || curl "$download_url" -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit

# shellcheck disable=SC2044
for path in $(find . -name "*.h"); do
  #head_file=${path##*/}
  head_path=${path%/*}
  head_save_path="$CD"/include/$head_path
  mkdir -p "$head_save_path" && cp "$path" "$head_save_path"
done

cd "$CD" || exit
rm -rf "$pkg"