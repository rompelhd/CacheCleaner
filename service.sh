#!/system/bin/sh

boot_completed() {
    while [ $(getprop sys.boot_completed) != 1 ]; do sleep 1; done
    local permission=/sdcard/.cache_cleaner
    touch $permission
    while [ ! -f $permission ]; do
        touch $permission
    done
    rm $permission

    . /data/adb/magisk/util_functions.sh
    mkdir -p /sdcard/CacheCleaner
    mktouch /sdcard/CacheCleaner/logs.txt
    cat <<EOF > /sdcard/CacheCleaner/settings.conf
# Configs for CacheCleaner
# DEFAULT 1GB, U CAN SET ANY IN MB OR GB
Threshold = "1GB"
EOF
}

boot_completed

nohup sh ${0%/*}/automatic.sh &
