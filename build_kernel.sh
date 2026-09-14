#!/usr/bin/env bash
#
# SesKernel - Samsung Galaxy M51 (SM7150) Yerel Derleme Betiği
#

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_DIR="${BASE_DIR}/kernel"
OUT_DIR="${KERNEL_DIR}/out"
TOOLCHAIN_DIR="${BASE_DIR}/toolchain"
ANYKERNEL_DIR="${BASE_DIR}/AnyKernel3"

echo "============================================="
echo "   SesKernel M51 (SM7150) Derleme Başlatılıyor"
echo "============================================="

# 1. Gerekli araç zincirlerinin kontrolü
if [ ! -d "${TOOLCHAIN_DIR}/clang" ]; then
    echo "Hata: ${TOOLCHAIN_DIR}/clang bulunamadı."
    echo "Lütfen AOSP Clang ve GCC araçlarını 'toolchain/' dizinine yerleştirin."
    exit 1
fi

export PATH="${TOOLCHAIN_DIR}/clang/bin:${TOOLCHAIN_DIR}/gcc-arm64/bin:${TOOLCHAIN_DIR}/gcc-arm/bin:${PATH}"
export ARCH=arm64
export SUBARCH=arm64
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-
export KBUILD_BUILD_USER="SesKernel"
export KBUILD_BUILD_HOST="LocalBuild"

cd "${KERNEL_DIR}"

# 2. Defconfig hazırlığı
echo "==> Yapılandırma dosyası hazırlanıyor: m51_defconfig"
make O=out m51_defconfig

# 3. Derleme
echo "==> Çekirdek derleniyor..."
make -j$(nproc --all) O=out \
    ARCH=arm64 \
    CC=clang \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-androideabi- \
    Image.gz-dtb dtbo.img || make -j$(nproc --all) O=out \
    ARCH=arm64 \
    CC=clang \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-androideabi- \
    Image.gz dtbo.img

# 4. Paketleme
if [ ! -d "${ANYKERNEL_DIR}" ]; then
    git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git "${ANYKERNEL_DIR}"
fi

cp -f "${BASE_DIR}/anykernel3/anykernel.sh" "${ANYKERNEL_DIR}/anykernel.sh"

if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz-dtb" ]; then
    cp "${OUT_DIR}/arch/arm64/boot/Image.gz-dtb" "${ANYKERNEL_DIR}/Image.gz-dtb"
elif [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz" ]; then
    cp "${OUT_DIR}/arch/arm64/boot/Image.gz" "${ANYKERNEL_DIR}/Image.gz"
elif [ -f "${OUT_DIR}/arch/arm64/boot/Image" ]; then
    gzip -c9 "${OUT_DIR}/arch/arm64/boot/Image" > "${ANYKERNEL_DIR}/Image.gz"
fi

if [ -f "${OUT_DIR}/arch/arm64/boot/dtbo.img" ]; then
    cp "${OUT_DIR}/arch/arm64/boot/dtbo.img" "${ANYKERNEL_DIR}/dtbo.img"
fi

DATE=$(date +"%Y%m%d-%H%M")
ZIP_NAME="SesKernel-M51-SM7150-${DATE}.zip"
cd "${ANYKERNEL_DIR}"
zip -r9 "${BASE_DIR}/${ZIP_NAME}" * -x .git README.md *placeholder

echo "============================================="
echo " Derleme Tamamlandı!"
echo " Çıktı Paketi: ${BASE_DIR}/${ZIP_NAME}"
echo "============================================="
