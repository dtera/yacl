#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

# build spdlog
# [ -d spdlog ] || git clone https://github.com/gabime/spdlog.git
pkg=spdlog-"$spdlog_ver"
download_url=https://github.com/gabime/spdlog/archive/refs/tags/v"$spdlog_ver".tar.gz
sh "$CD"/build_template.sh --pkg "$pkg" -u "$download_url"
