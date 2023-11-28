#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# =================================================================================================================
# ==============================================Prepare Begin======================================================
# =================================================================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install grpc
    # exit 0
#elif [[ "$OSTYPE" == "linux"* ]]; then   # not work for posix shell
elif echo "$OSTYPE" | grep -q "linux" || [[ "$OSTYPE" == "" ]]; then
  os_release=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
  if [ "$os_release" == "manjaro" ]; then
    pacman -Sy openssl cmake autoconf libtool pkg-config clang
  elif [ "$os_release" == "ubuntu" ]; then
    apt-get update && apt-get install -y cmake libssl-dev build-essential autoconf libtool pkg-config libc-ares-dev
  else
    yum -y install openssl cmake autoconf libtool pkg-config centos-release-scl devtoolset-7-gcc* \
      tbb tbb-devel gtest-devel gmock-devel gmp-devel
  fi
else
  echo "not supported os type: ${OSTYPE}"
  exit 1
fi
# =================================================================================================================
# ==============================================Prepare End========================================================
# =================================================================================================================

# =================================================================================================================
# ==============================================Install gRPC Begin=================================================
# =================================================================================================================
# grpc@version     protobuf@version
#   1.4.3              3.3.0
#   1.41.0             3.17.3
#   1.54.0             3.21.12
ver=1.54.0
if [ "$1" != "" ] && [ "$1" != "clone" ]; then
  ver="$1"
fi
echo "grpc version: v$ver"

cd "$CD"/src || exit
if [ "$1" == "clone" ]; then
  rm -rf grpc && git clone --recurse-submodules -b "v$ver" --depth 1 --shallow-submodules https://github.com/grpc/grpc
fi

cd "$CD"/src/grpc || exit
#git submodule update --init
#prefix=/usr/local/grpc
prefix="$CD"/grpc
#rm -rf "$install_prefix"
min_ver=${ver#*\.}
#if [ "$ver" == "1.35.0" ]; then
if [ "${min_ver%\.*}" -gt 35 ]; then
  # wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh
  # sh cmake-linux.sh -- --skip-license --prefix=/usr/local/cmake && rm cmake-linux.sh
  # cmk=/usr/local/cmake/bin/cmake
  # git clone -b "$(curl -L https://grpc.io/release)" https://github.com/grpc/grpc
  rm -rf cmake/build && mkdir -p cmake/build && pushd cmake/build || exit
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DgRPC_INSTALL=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DgRPC_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_TESTS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
    -DCMAKE_INSTALL_PREFIX="$prefix" ../..
  make -j8 && make install
  popd || exit
  cd - && cd ..
else
  # Install absl
  printf "Trying to install abseil...\n"
  mkdir -p third_party/abseil-cpp/cmake/build && cd third_party/abseil-cpp/cmake/build || exit
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
    -DCMAKE_INSTALL_PREFIX="$prefix" ../.. && make -j8 install && cd - || exit

  # Install c-ares
  # If the distribution provides a new-enough version of c-ares, this section can be replaced with:
  # apt-get install -y libc-ares-dev
  printf "Trying to install cares...\n"
  mkdir -p third_party/cares/cares/cmake/build && cd third_party/cares/cares/cmake/build || exit
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$prefix" ../.. && make -j8 install && cd - || exit

  # Install protobuf
  printf "Trying to install protobuf...\n"
  mkdir -p third_party/protobuf/cmake/build && cd third_party/protobuf/cmake/build || exit
  cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" .. && make -j8 install && cd - || exit

  # Install re2
  printf "Trying to install re2...\n"
  mkdir -p third_party/re2/cmake/build && cd third_party/re2/cmake/build || exit
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
    -DCMAKE_INSTALL_PREFIX="$prefix" ../.. && make -j8 install && cd - || exit

  # Install zlib
  printf "Trying to install zlib...\n"
  mkdir -p third_party/zlib/cmake/build && cd third_party/zlib/cmake/build || exit
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$prefix" ../.. && make -j8 install && cd - || exit

  # Install gRPC
  printf "Trying to install gRPC...\n"
  mkdir -p cmake/build && cd cmake/build || exit
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DgRPC_INSTALL=ON \
    -DgRPC_BUILD_TESTS=OFF \
    -DgRPC_CARES_PROVIDER=package \
    -DgRPC_ABSL_PROVIDER=package \
    -DgRPC_PROTOBUF_PROVIDER=package \
    -DgRPC_RE2_PROVIDER=package \
    -DgRPC_SSL_PROVIDER=package \
    -DgRPC_ZLIB_PROVIDER=package \
    -DCMAKE_INSTALL_PREFIX="$prefix"
  ../.. && make -j8 install && cd - || exit
fi
#rm -rf $prefix && ln -s "$install_prefix" $prefix
#cp -R $prefix/include/* $CD/include && cp -R $prefix/lib/* $CD/lib
#grep -q 'export LD_LIBRARY_PATH' ~/.bashrc || export LD_LIBRARY_PATH="/usr/local/grpc/lib:/usr/local/grpc/lib64:$LD_LIBRARY_PATH"
#grep -q 'export LDFLAGS' ~/.bashrc || export LDFLAGS="-Wl,--copy-dt-needed-entries"
#grep -q 'export LD_LIBRARY_PATH' ~/.bashrc || echo "export LD_LIBRARY_PATH=/usr/local/grpc/lib:/usr/local/grpc/lib64:$LD_LIBRARY_PATH" >>~/.bashrc
#grep -q 'export LDFLAGS' ~/.bashrc || echo "export LDFLAGS=-Wl,--copy-dt-needed-entries" >>~/.bashrc
# =================================================================================================================
# ==============================================Install gRPC End===================================================
# =================================================================================================================
