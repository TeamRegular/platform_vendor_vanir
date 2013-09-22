#Squisher Choosing
DHO_VENDOR := vanir
 
PRODUCT_PROPERTY_OVERRIDES += \
    drm.service.enabled=true \
    ro.goo.rom=vanir-hercules

# Boot Animation
PRODUCT_COPY_FILES += \
    vendor/vanir/proprietary/boot_animations/480x480.zip:system/media/bootanimation.zip

# Vanir configuration
$(call inherit-product, vendor/vanir/products/common_phones.mk)
$(call inherit-product, vendor/vanir/products/gsm.mk)
 
# Inherit AOSP device configuration for exhilarate.
$(call inherit-product, device/samsung/exhilarate/full_exhilarate.mk)

# Setup device specific product configuration.
PRODUCT_NAME := vanir_exhilarate
PRODUCT_DEVICE := exhilarate
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_MODEL := SAMSUNG-SGH-I577

# Setup device specific product configuration.
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=SGH-I577 TARGET_DEVICE=SGH-I577 BUILD_FINGERPRINT="samsung/SGH-I577/SGH-I577:4.3/JZO54K/UCMC1:user/release-keys" PRIVATE_BUILD_DESC="SGH-I577-user 4.3 JZO54K UCMC1 release-keys"
