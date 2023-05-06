#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from sm6225-common
$(call inherit-product, device/motorola/sm6225-common/bengal.mk)

# Audio - Configs
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_platform_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info.xml \
    $(LOCAL_PATH)/audio/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    $(LOCAL_PATH)/audio/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml

# Boot animation
TARGET_SCREEN_HEIGHT := 1600
TARGET_SCREEN_WIDTH := 720

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc@1.2-service

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml

# Overlay
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

# Rootdir
PRODUCT_PACKAGES += \
    fstab.qcom_emmc \
    init.oem.fingerprint.sh \
    init.oem.fingerprint2.sh \
    init.mmi.overlay.rc

# Permissions
DEVICE_NFC_SKUS := b bc d dc f fc
DEVICE_COMPASS_SKUS := b d dn f n

PRODUCT_COPY_FILES += \
$(foreach DEVICE_SKU, $(DEVICE_NFC_SKUS), \
    $(LOCAL_PATH)/permissions/unavail.android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_SKU)/unavail.android.hardware.nfc.hce.xml \
    $(LOCAL_PATH)/permissions/unavail.android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_SKU)/unavail.android.hardware.nfc.hcef.xml \
    $(LOCAL_PATH)/permissions/unavail.android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_SKU)/unavail.android.hardware.nfc.uicc.xml \
    $(LOCAL_PATH)/permissions/unavail.android.hardware.nfc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_SKU)/unavail.android.hardware.nfc.xml)

PRODUCT_COPY_FILES += \
$(foreach DEVICE_SKU, $(DEVICE_COMPASS_SKUS), \
    $(LOCAL_PATH)/permissions/unavail.android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_SKU)/unavail.android.hardware.sensor.compass.xml)

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 30

# Get non-open-source specific aspects
$(call inherit-product-if-exists, vendor/motorola/caprip/caprip-vendor.mk)
