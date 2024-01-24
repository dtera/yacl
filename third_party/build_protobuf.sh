#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build protobuf
 [ -d protobuf ] || git clone --recursive -b "v$protobuf_ver" https://github.com/protocolbuffers/protobuf.git
pkg=protobuf
cd "$pkg" && rm -rf build && mkdir build && cd build || exit
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
-Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_WITH_ZLIB=OFF \
-Dprotobuf_ABSL_PROVIDER=package \
-DCMAKE_PREFIX_PATH=$CD \
-DCMAKE_INSTALL_PREFIX=$CD -DCMAKE_CXX_STANDARD=17 ..
#cmake --build . --parallel 10 --target libprotobuf-lite libprotobuf libprotoc protoc
make -j8 libprotobuf-lite libprotobuf libprotoc protoc && make install
#cp -R libproto* "$CD"/lib && cp -R protoc "$CD"/bin  # third_party/utf8_range/libutf8_validity.a
cd "$CD" || exit
rm -rf "$pkg"

#pkg=protobuf-"$protobuf_ver"
#download_url=https://github.com/protocolbuffers/protobuf/releases/download/v"$protobuf_ver"/protobuf-all-"$protobuf_ver".tar.gz
#sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url" --build_dir "cmake_build" \
#-o "-Dprotobuf_ABSL_PROVIDER=package -DCMAKE_PREFIX_PATH=$CD"
