#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build libsodium
# [ -d libsodium ] || https://github.com/jedisct1/libsodium.git
pkg=brpc-"$brpc_ver"
[ -f src/"$pkg".tar.gz ] || curl https://github.com/apache/brpc/archive/refs/tags/"$brpc_ver".tar.gz -L -o src/"$pkg".tar.gz
rm -rf "$pkg" && tar xvf src/"$pkg".tar.gz && cd "$pkg" || exit

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install openssl git gnu-getopt coreutils gflags protobuf gperftools
  echo $PATH|grep -q "gnu-getopt" || export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"
#elif [[ "$OSTYPE" == "linux"* ]]; then   # not work for posix shell
elif echo "$OSTYPE" | grep -q "linux" || [[ "$OSTYPE" == "" ]]; then
  os_release=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
  if [[ "$os_release" == "ubuntu" ]]; then
    apt-get update && apt-get install -y git g++ make cmake libssl-dev libgflags-dev libprotobuf-dev libprotoc-dev \
    protobuf-compiler libleveldb-dev libsnappy-dev libgoogle-perftools-dev libgtest-dev
  else
    yum -y install epel-release git gcc-c++ make openssl-devel gflags-devel protobuf-devel protobuf-compiler \
    leveldb-devel gperftools-devel gtest-devel
  fi
else
  echo "not supported os type: ${OSTYPE}"
  exit 1
fi

#sh config_brpc.sh --headers="$CD"/include --libs="$CD"/lib --cc=clang --cxx=clang++
#make
mkdir build && cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX="$CD/" ..
make -j8

cd "$CD" || exit
rm -rf "$pkg"
