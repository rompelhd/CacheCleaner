#!/system/bin/sh

SKIPUNZIP=1

module_descriptions() {
    ui_print "Cache Cleaner"
    ui_print " • A simple module to clean all apps cache on your device."
    ui_print " • Automatically runs if total cache size exceeds 1GB."
    ui_print " • Can also be triggered manually with 'su -c cleaner' in the Terminal."
    ui_print ""
    ui_print "Notes:"
    ui_print " • This module only clears the applications cache"
    ui_print " • Specifically in the 'cache' and 'code_cache' directories."
    ui_print ""
}

install_module() {
    module_descriptions
    ui_print "Installing..."
    ui_print "- Extracting module files"
    unzip -o "$ZIPFILE" "automatic.sh" -d $MODPATH >&2
    unzip -o "$ZIPFILE" "cleaner" -d $MODPATH >&2
    unzip -o "$ZIPFILE" "module.prop" -d $MODPATH >&2
    unzip -o "$ZIPFILE" "service.sh" -d $MODPATH >&2
    ui_print "- Settings module"
    mkdir -p $MODPATH/system/bin
    mv $MODPATH/cleaner $MODPATH/system/bin/cleaner
    ui_print "- Settings permission"
    set_perm_recursive $MODPATH 0 0 0755 0644
    set_perm $MODPATH/system/bin/cleaner 0 0 0755
}

if [ $API -lt 21 ]; then
    ui_print "*********************************************************"
    ui_print " Requires API 21+ (Android 5.0+) to install this module! "
    abort "*********************************************************"
elif [ $MAGISK_VER_CODE -lt 23000 ]; then
    ui_print "*******************************"
    ui_print " Please install Magisk v23.0+! "
    abort "*******************************"
elif ! $BOOTMODE; then
    ui_print "********************************"
    ui_print " Install this module in Magisk! "
    abort "********************************"
else
    set -x
    install_module
fi
