#!/vendor/bin/sh
#
# Identify fingerprint sensor model
#
# Copyright (c) 2019 Lenovo
# All rights reserved.
#
# Changed Log:
# ---------------------------------
# April 15, 2019  chengql2@lenovo.com  Initial version
# April 28, 2019  chengql2  Add fps_id creating step
#

script_name=${0##*/}
script_name=${script_name%.*}
function log {
    echo "$script_name: $*" > /dev/kmsg
}

persist_fps_id=/mnt/vendor/persist/fps/vendor_id

FPS_VENDOR_CHIPONE=chipone
FPS_VENDOR_FPC=fpc
FPS_VENDOR_NONE=none

PROP_FPS_IDENT=vendor.hw.fps.ident
MAX_TIMES=20

function ident_fps {
    log "- install FPC driver"
    insmod /vendor/lib/modules/fpc1020_mmi.ko
    sleep 1
    restorecon -R /sys/class/fingerprint
    restorecon -R /sys/devices/virtual/fingerprint
    log "- identify FPC sensor"
    setprop $PROP_FPS_IDENT ""
    start fpc_ident
    for i in $(seq 1 $MAX_TIMES)
    do
        sleep 0.1
        ident_status=$(getprop $PROP_FPS_IDENT)
        log "- result: $ident_status"
        if [ $ident_status == $FPS_VENDOR_FPC ]; then
            log "ok"
            echo $FPS_VENDOR_FPC > $persist_fps_id
            return 0
        elif [ $ident_status == $FPS_VENDOR_NONE ]; then
            log "fail"
            log "- remove FPC driver"
            rmmod fpc1020_mmi
            break
        fi
    done

    log "- install Chipone driver"
    insmod /vendor/lib/modules/fpsensor_spi_tee.ko
    echo $FPS_VENDOR_CHIPONE > $persist_fps_id
    return 0
}

if [ ! $persist_fps_id ]; then
    log "- start ident_fps"
    ident_fps
    return $?
fi

fps_vendor=$(cat $persist_fps_id)
log "FPS vendor: $fps_vendor"

if [ $fps_vendor == $FPS_VENDOR_CHIPONE ]; then
    log "- install Chipone driver"
    insmod /vendor/lib/modules/fpsensor_spi_tee.ko
    return $?
fi

if [ $fps_vendor == $FPS_VENDOR_FPC ]; then
    log "- install FPC driver"
    insmod /vendor/lib/modules/fpc1020_mmi.ko
    return $?
fi

ident_fps
return $?
