#!/bin/bash

echo "========================"
echo "removing local manifests"
echo "========================"

rm -rf .repo/local_manifests;
rm -rf out/soong/.intermediates/system/sepolicy;

echo "====================="
echo "      repo init      "
echo "====================="

repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --depth=1 --git-lfs

echo "==================="
echo "     repo sync     "
echo "==================="

/opt/crave/resync.sh;

echo "==================="
echo " clone device tree "
echo "==================="

# Device
git clone https://github.com/SiliconxLab/android_device_xiaomi_air device/xiaomi/air;

# Kernel (prebuilt)
git clone https://github.com/SiliconxLab/device_xiaomi_air-kernel device/xiaomi/air-kernel;

# Vendor
git clone https://gitlab.com/noescape-firmware-dumps/REDMI/air.git dump/air
cd device/xiaomi/air
./extract-files.py ../../../dump/air
cd ../../..

# Mediatek IMS
git clone https://github.com/SiliconxLab/android_vendor_mediatek_ims vendor/mediatek/ims;

# Mediatek sepolicy_vndr
git clone https://github.com/SiliconxLab/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr;

# Xiaomi Components
git clone https://github.com/SiliconxLab/android_hardware_xiaomi hardware/xiaomi;

# Sign Builds
git clone https://github.com/suchit-7x/android_vendor_lineage-priv_keys vendor/lineage-priv/keys;
cd vendor/lineage-priv/keys
./keys.sh
cd ../../..

echo "======================="
echo "   setup environment   "
echo "======================="

# Setup Environment
sudo apt-get update && sudo apt-get install patchelf coreutils -y;

export BUILD_USERNAME=suchit
export BUILD_HOSTNAME=foss

rm -rf build/soong/fsgen;

echo "build started!..."

. build/envsetup.sh;
lunch lineage_air-bp4a-userdebug;
m bacon -j$(nproc --all);

echo "Upload to GoFile will be started..."

ZIP=$(find out/target/product/air -maxdepth 1 -type f -name "*.zip" | head -n 1)

if [ -n "$ZIP" ]; then
    echo "Uploading $ZIP..."
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh
    ./upload.sh "$ZIP"
else
    echo "No ROM ZIP found!"
    exit 1
fi



