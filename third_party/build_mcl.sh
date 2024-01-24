#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build mcl
# [ -d mcl ] || git clone https://github.com/herumi/mcl.git
pkg=mcl-"$mcl_ver"
download_url=https://github.com/herumi/mcl/archive/refs/tags/v"$mcl_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url"
