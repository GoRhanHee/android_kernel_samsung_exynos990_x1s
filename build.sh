#!/bin/bash

# Import KernelSU-Next
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/legacy/kernel/setup.sh" | bash -s legacy

# Import Cross Compiler
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9  \
 toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9

# Import clang-r349610
git clone -b android10-release --depth 1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 \
 toolchain/clang/host/linux-x86/clang-r349610-jopp

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
