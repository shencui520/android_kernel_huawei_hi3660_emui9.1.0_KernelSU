#!/system/bin/sh

SKIPUNZIP=0

STATE_DIR=/data/adb/hi3660-server
CONFIG_FILE="$STATE_DIR/server.conf"

ui_print "- Installing Hi3660 Linux Server Runtime"
mkdir -p "$STATE_DIR" "$STATE_DIR/run" "$STATE_DIR/log"
chmod 700 "$STATE_DIR" "$STATE_DIR/run" "$STATE_DIR/log"

if [ ! -f "$CONFIG_FILE" ]; then
    cp "$MODPATH/server.conf.example" "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    ui_print "- Created $CONFIG_FILE"
else
    ui_print "- Preserving existing $CONFIG_FILE"
fi

chmod 0755 "$MODPATH/service.sh" "$MODPATH/uninstall.sh" "$MODPATH/bin/serverctl"
ui_print "- Storage image and Linux rootfs are not created automatically"
ui_print "- Run serverctl init-storage after reboot"
