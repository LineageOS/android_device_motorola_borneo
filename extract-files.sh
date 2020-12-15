#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib64/com.qti.feature2.rt.so | \
            vendor/lib64/hw/camera.qcom.so | \
            vendor/lib64/hw/com.qti.chi.override.so)
            [ "$2" = "" ] && return 0
            sed -i "s/camera.mot.is.coming.cts/vendor.camera.coming.cts/g" "${2}"
            ;;
        vendor/lib64/libvidhance.so)
            [ "$2" = "" ] && return 0
            grep -q libcomparetf2_shim.so "${2}" || "${PATCHELF}" --add-needed libcomparetf2_shim.so "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=borneo
export DEVICE_COMMON=sm6225-common
export VENDOR=motorola
export VENDOR_COMMON=${VENDOR}

"./../../${VENDOR_COMMON}/${DEVICE_COMMON}/extract-files.sh" "$@"
