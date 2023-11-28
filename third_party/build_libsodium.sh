#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build libsodium
# [ -d libsodium ] || https://github.com/jedisct1/libsodium.git
pkg=libsodium-"$libsodium_ver"
[ -f src/"$pkg".tar.gz ] || curl https://download.libsodium.org/libsodium/releases/"$pkg".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit

arch_name=$(arch)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ "$arch_name" == "aarch64"* ]] || [[ "$arch_name" == "arm64"* ]]; then
    # ARM64
    env CFLAGS="$CFLAGS -march=armv8-a+crypto+aes" ./configure --prefix="$CD/"
  elif [[ "$arch_name" == *"86"* ]] || [[ "$arch_name" == "amd"* ]] || [[ "$arch_name" == *"64"* ]]; then
    # AMD64
    ./configure --prefix="$CD/"
  fi
#elif [[ "$OSTYPE" == "linux"* ]]; then   # not work for posix shell
elif echo "$OSTYPE" | grep -q "linux" || [[ "$OSTYPE" == "" ]]; then
  ./config --prefix="$CD/"
else
  echo "not supported os type: ${OSTYPE}"
  exit 1
fi

make -j8 && make install

cd src/libsodium/include || exit
# shellcheck disable=SC2044
for path in $(find sodium/private -name "*.h"); do
  #head_file=${path##*/}
  head_path=${path%/*}
  head_save_path="$CD"/include/$head_path
  mkdir -p "$head_save_path" && cp "$path" "$head_save_path"
done

cd ../.. || exit
# shellcheck disable=SC2044
for path in $(find libsodium -name "*.h"); do
  # [[ "$path" == "libsodium/include"* ]] && continue
  echo "$path" | grep -q "libsodium/include" && continue
  #head_file=${path##*/}
  head_path=${path%/*}
  head_save_path="$CD"/include/$head_path
  mkdir -p "$head_save_path" && cp "$path" "$head_save_path"
done

cd "$CD" && rm -rf "$CD"/lib/libsodium.la || exit
rm -rf "$pkg"
