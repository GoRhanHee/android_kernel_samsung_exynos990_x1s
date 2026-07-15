#!/bin/bash

# Import XXSU
curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/master/kernel/setup.sh" | bash -

# Import Cross Compiler
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9  \
 toolchain/gcc-cfp/gcc-cfp-jopp-only/aarch64-linux-android-4.9

# Import clang-r349610
TOOLCHAIN_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android10-release/clang-r349610.tar.gz"
CLANG_PATH="toolchain/clang/host/linux-x86/clang-r349610-jopp"
mkdir -p "$CLANG_PATH"
TOOLCHAIN_FILE=$(basename "$TOOLCHAIN_URL")
if [ ! -f "$TOOLCHAIN_FILE" ]; then
    wget -q --show-progress -O "$TOOLCHAIN_FILE" "$TOOLCHAIN_URL"
fi
tar -xf "$TOOLCHAIN_FILE" -C "$CLANG_PATH" && rm "$TOOLCHAIN_FILE"

export ANDROID_BUILD_TOP=$(pwd)

# OEM Setting
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r 
export ARCH=arm64
export SEC_BUILD_CONF_VENDOR_BUILD_OS=13

# Cooking Kernel Source
MAKE_ARGS="
ARCH=arm64 \
-j16 \
O=out
"

make ${MAKE_ARGS} exynos9830-x1slte_defconfig gorhanhee.config || exit 1
make ${MAKE_ARGS} || exit 1

mkdir prebuilts/output
chmod +x ${ANDROID_BUILD_TOP}/prebuilts/*

# Cooking dtb.img
# Idea from @xfwdrev exynos2100 kernel source (https://github.com/xfwdrev/android_kernel_samsung_ex2100/blob/12-upstream/build.sh)
./prebuilts/mkdtimg cfg_create ${ANDROID_BUILD_TOP}/prebuilts/output/dtb.img ${ANDROID_BUILD_TOP}/prebuilts/dt_configs/exynos9830.cfg -d ${ANDROID_BUILD_TOP}/out/arch/arm64/boot/dts/exynos

# Cooking dtbo.img
# Idea from @xfwdrev exynos2100 kernel source (https://github.com/xfwdrev/android_kernel_samsung_ex2100/blob/12-upstream/build.sh)
./prebuilts/mkdtimg cfg_create ${ANDROID_BUILD_TOP}/prebuilts/output/dtbo.img ${ANDROID_BUILD_TOP}/prebuilts/dt_configs/x1s.cfg -d ${ANDROID_BUILD_TOP}/out/arch/arm64/boot/dts/samsung

cd ${ANDROID_BUILD_TOP}/prebuilts

# Cooking boot.img
unzip -jo ${ANDROID_BUILD_TOP}/prebuilts/boot.zip boot.img -d ${ANDROID_BUILD_TOP}/prebuilts/
./magiskboot unpack boot.img
cp ${ANDROID_BUILD_TOP}/out/arch/arm64/boot/Image ${ANDROID_BUILD_TOP}/prebuilts/kernel
cp ${ANDROID_BUILD_TOP}/prebuilts/output/dtb.img ${ANDROID_BUILD_TOP}/prebuilts/dtb
./magiskboot repack boot.img
cp ${ANDROID_BUILD_TOP}/prebuilts/new-boot.img ${ANDROID_BUILD_TOP}/prebuilts/output/boot.img

# Cooking flashable file
cd ${ANDROID_BUILD_TOP}/prebuilts/output
tar -cvf x1s_KSU_Odin.tar boot.img dtbo.img