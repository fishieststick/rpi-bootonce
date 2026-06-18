#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="$(grep '^VERSION=' bootonce | head -n1 | cut -d'"' -f2)"
PKG="bootonce"
ARCH="all"
BUILD_DIR="build/${PKG}_${VERSION}_${ARCH}"
DEB="dist/${PKG}_${VERSION}_${ARCH}.deb"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/DEBIAN" "$BUILD_DIR/usr/sbin" dist

install -m 0755 bootonce "$BUILD_DIR/usr/sbin/bootonce"

cat > "$BUILD_DIR/DEBIAN/control" <<EOF
Package: bootonce
Version: ${VERSION}
Section: admin
Priority: optional
Architecture: all
Maintainer: Marvin <marvin-kolia@live.de>
Depends: bash, coreutils, util-linux, mount, sed, gawk | awk, grep, findutils, passwd, systemd, wget | curl
Conflicts: usbboot-temp-override
Replaces: usbboot-temp-override
Description: Raspberry Pi 5 and CM5 one-time boot and recovery helper
 bootonce provides a short, verbose command interface for Pi 5 and CM5
 one-time USB/NVMe boot override, offline OS restore, Connect setup,
 and recovery image creation.
EOF

dpkg-deb --build "$BUILD_DIR" "$DEB"
sha256sum "$DEB" > "dist/${PKG}_${VERSION}_SHA256SUMS.txt"

echo "Built: $DEB"
echo "Checksum: dist/${PKG}_${VERSION}_SHA256SUMS.txt"
