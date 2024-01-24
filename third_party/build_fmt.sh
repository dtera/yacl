#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build fmt
# [ -d fmt ] || git clone https://github.com/fmtlib/fmt.git
pkg=fmt-"$fmt_ver"
download_url=https://github.com/fmtlib/fmt/archive/refs/tags/"$fmt_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url"
