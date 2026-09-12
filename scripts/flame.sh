#!/bin/bash

echo "========================"
echo "removing local manifests"
echo "========================"

rm -rf .repo/local_manifests;
rm -rf out/soong/.intermediates/system/sepolicy;

echo "====================="
echo "      repo init      "
echo "====================="

repo init -u https://github.com/Evolution-X/manifest -b bka  --depth=1 --git-lfs

echo "==================="
echo "     repo sync     "
echo "==================="

/opt/crave/resync.sh;

echo "==================="
echo " clone device tree "
echo "==================="

# Device
git clone https://github.com/SiliconxLab/android_device_xiaomi_flame device/xiaomi/flame;

# Kernel (prebuilt)
git clone https://github.com/bitstash-io/device_xiaomi_flame-kernel device/xiaomi/flame-kernel;

# Vendor
git clone https://github.com/SiliconxLab/android_vendor_xiaomi_flame vendor/xiaomi/flame;

# Firmware
git clone https://github.com/bitstash-io/vendor_xiaomi_flame-firmware vendor/xiaomi/flame-firmware;

# Xiaomi Components
git clone https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi;

# Sign Builds
git clone https://github.com/suchit-7x/evolution-priv_keys vendor/evolution-priv/keys;
cd vendor/evolution-priv/keys
./keys.sh
cd ../../..
zip -r keys.zip vendor/evolution-priv/keys

echo "======================="
echo "   setup environment   "
echo "======================="

# Setup Environment
sudo apt-get update && sudo apt-get install patchelf coreutils -y;

export BUILD_USERNAME=suchit
export BUILD_HOSTNAME=crave

rm -rf build/soong/fsgen;

echo "build started!..."

. build/envsetup.sh;
lunch lineage_flame-bp4a-userdebug;
m evolution -j$(nproc --all);

echo "Upload to GoFile will be started..."

ZIP=$(find out/target/product/flame -maxdepth 1 -type f -name "*.zip" | head -n 1)

if [ -n "$ZIP" ]; then
    echo "Uploading $ZIP..."
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh
    echo "Uploading start!..."
    ./upload.sh "$ZIP"
    echo "Upload sign keys"
    curl sendit.sh -T keys.zip
else
    echo "No ROM ZIP found!"
    exit 1
fi



