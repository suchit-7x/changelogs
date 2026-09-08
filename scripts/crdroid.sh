#!/bin/bash

echo "========================"
echo "removing local manifests"
echo "========================"

rm -rf .repo/local_manifests;
rm -rf out/soong/.intermediates/system/sepolicy;

echo "====================="
echo "      repo init      "
echo "====================="

repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --git-lfs --no-clone-bundle --depth=1

echo "==================="
echo "     repo sync     "
echo "==================="

/opt/crave/resync.sh;

echo "==================="
echo " clone device tree "
echo "==================="

# Device
git clone https://github.com/SiliconxLab/android_device_xiaomi_spring device/xiaomi/spring;

# Kernel (prebuilt)
git clone https://gitlab.com/Niyush-04/android_device_xiaomi_spring-kernel.git device/xiaomi/spring-kernel;

# Vendor
git clone https://github.com/spring4ever/android_vendor_xiaomi_spring vendor/xiaomi/spring;

# Custom HALs
rm -rf hardware/qcom-caf/common;

git clone https://github.com/spring4ever/android_hardware_qcom-caf_common hardware/qcom-caf/common;

git clone https://github.com/spring4ever/android_vendor_qcom_opensource_agm hardware/qcom-caf/sm6375-6.1/audio/agm;

git clone https://github.com/spring4ever/android_vendor_qcom_opensource_arpal-lx hardware/qcom-caf/sm6375-6.1/audio/pal;

git clone https://github.com/spring4ever/android_hardware_qcom_audio-ar hardware/qcom-caf/sm6375-6.1/audio/primary-hal;

git clone https://github.com/spring4ever/android_vendor_qcom_opensource_audioreach-graphservices hardware/qcom-caf/sm6375-6.1/audio/graphservices;

git clone https://github.com/spring4ever/android_hardware_qcom_display hardware/qcom-caf/sm6375-6.1/display;

git clone https://github.com/spring4ever/android_vendor_qcom_opensource_dataipa hardware/qcom-caf/sm6375-6.1/dataipa;

git clone https://github.com/spring4ever/android_vendor_qcom_opensource_data-ipa-cfg-mgr hardware/qcom-caf/sm6375-6.1/data-ipa-cfg-mgr;

ln -sf ../common/os_pickup_qssi.bp hardware/qcom-caf/sm6375-6.1/Android.bp;

# Xiaomi Components
git clone https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi;

# Gapps
git clone https://github.com/MindTheGapps/vendor_gapps -b baklava vendor/gms

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

export BUILD_USERNAME=Suchit
export BUILD_HOSTNAME=foss

rm -rf build/soong/fsgen;

echo "build started!..."

. build/envsetup.sh;
brunch spring;

echo "Upload to GoFile will be started..."

ZIP=$(find out/target/product/spring -maxdepth 1 -type f -name "*.zip" | head -n 1)

if [ -n "$ZIP" ]; then
    echo "Uploading $ZIP..."
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh
    echo "............"
    ./upload.sh "$ZIP"
    echo "....."
    echo "...."
    echo "..."
    echo ".."
    echo "."
    echo ""
else
    echo "No ROM ZIP found!"
    exit 1
fi



