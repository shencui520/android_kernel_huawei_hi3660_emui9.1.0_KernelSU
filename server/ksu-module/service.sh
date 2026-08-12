#!/system/bin/sh

MODDIR=${0%/*}

# Android has completed its own mounts before KernelSU runs service scripts.
"$MODDIR/bin/serverctl" boot >>/data/adb/hi3660-server/log/service.log 2>&1 &
