#!/system/bin/sh

MODDIR=${0%/*}

"$MODDIR/bin/serverctl" shutdown >/dev/null 2>&1 || true

# Deliberately keep /data/adb/hi3660-server and its ext4 image. Removing a
# module must not delete container images or an imported Linux system.
