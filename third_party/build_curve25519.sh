#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build curve25519-donna
# [ -d curve25519-donna ] || https://github.com/floodyberry/curve25519-donna.git
pkg=curve25519-donna-"$curve25519_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/floodyberry/curve25519-donna/archive/"$curve25519_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit

# shellcheck disable=SC2044
for path in $(find . -name "*.h"); do
  #head_file=${path##*/}
  head_path=${path%/*}
  head_save_path="$CD"/include/$head_path
  mkdir -p "$head_save_path" && cp "$path" "$head_save_path"
done

gcc curve25519.c -m64 -O3 -c && ar -r libcurve25519.a curve25519.o && cp libcurve25519.a "$CD"/lib/

cd "$CD" || exit
rm -rf "$pkg"
