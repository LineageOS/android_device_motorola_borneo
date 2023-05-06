#!/vendor/bin/sh
#
# Start indicated fingerprint HAL service
#
# Copyright (c) 2019 Lenovo
# All rights reserved.
#
# author: chengql2@lenovo.com
# date: April 15, 2019
#

script_name=${0##*/}
script_name=${script_name%.*}
function log {
    echo "$script_name: $*" > /dev/kmsg
}

persist_fps_id=/mnt/vendor/persist/fps/vendor_id
persist_fps_id2=/mnt/vendor/persist/fps/last_vendor_id

if [ ! -f $persist_fps_id ]; then
    log "warn: no associated persist file found"
    return -1
fi

fps_vendor2=$(cat $persist_fps_id2)
log "FPS vendor (last): $fps_vendor2"
fps_vendor=$(cat $persist_fps_id)
log "FPS vendor: $fps_vendor"

FPS_VENDOR_NONE=none
FPS_VENDOR_CHIPONE=chipone
FPS_VENDOR_FPC=fpc

prop_fps_status=vendor.hw.fingerprint.status
prop_persist_fps=persist.vendor.hardware.fingerprint

FPS_STATUS_NONE=none
FPS_STATUS_OK=ok

if [ $fps_vendor == $FPS_STATUS_NONE ]; then
    log "warn: boot as the last FPS"
    fps=$fps_vendor2
else
    fps=$fps_vendor
fi

for i in $(seq 1 2)
do

setprop $prop_fps_status $FPS_STATUS_NONE
if [ $fps == $FPS_VENDOR_FPC ]; then
    log "start fps_hal"
    start fps_hal
else
    log "start fpsensor_hal"
    start chipone_fp_hal
    fps=$FPS_VENDOR_CHIPONE
fi

log "wait for HAL finish ..."
fps_status=$(getprop $prop_fps_status)
log "fingerprint HAL status: $fps_status"
while [ $fps_status == $FPS_STATUS_NONE ]; do
    sleep 0.2
    fps_status=$(getprop $prop_fps_status)
done
log "fingerprint HAL status: $fps_status"

if [ $fps_status == $FPS_STATUS_OK ]; then
    log "HAL success"
    setprop $prop_persist_fps $fps
    if [ $fps_vendor2 == $fps ]; then
        return 0
    fi
    log "- update FPS vendor (last)"
    echo $fps > $persist_fps_id2
    log "- done"
    return 0
fi

if [ $fps == $fps_vendor2 ]; then
    if [ $fps == $FPS_VENDOR_FPC ]; then
        log "remove FPC driver"
        rmmod fpc1020_mmi
        log "- install chipone driver"
        insmod /vendor/lib/modules/fpsensor_spi_tee.ko
        fps=$FPS_VENDOR_CHIPONE
    else
        log "remove chipone driver"
        rmmod fpsensor_spi_tee
        log "- install fpc driver"
        insmod /vendor/lib/modules/fpc1020_mmi.ko
        fps=$FPS_VENDOR_FPC
    fi
    log "- update FPS vendor"
    echo $fps > $persist_fps_id
    sleep 1
else
    log "error: HAL fail"
    setprop $prop_persist_fps $FPS_VENDOR_NONE
    echo $FPS_VENDOR_NONE > $persist_fps_id

    log "- done"
    return 1
fi

done
