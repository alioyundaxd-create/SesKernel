#!/bin/bash
# Boeffla Wakelock Blocker otomatik entegrasyon betiği

KERNEL_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$KERNEL_DIR" ] || [ ! -d "$KERNEL_DIR" ]; then
    echo "Hata: Geçerli bir kernel dizini belirtilmedi."
    echo "Kullanım: $0 /yol/kernel"
    exit 1
fi

echo "==> Boeffla Wakelock Blocker entegre ediliyor: $KERNEL_DIR"

# 1. Başlık dosyasını include/linux altına yerleştir
cp -f "$SCRIPT_DIR/boeffla_wl_blocker.h" "$KERNEL_DIR/include/linux/boeffla_wl_blocker.h"

# 2. Sürücü kaynak dosyasını drivers/misc altına kopyala
cp -f "$SCRIPT_DIR/boeffla_wl_blocker.c" "$KERNEL_DIR/drivers/misc/boeffla_wl_blocker.c"

# 3. drivers/misc/Makefile dosyasına sürücüyü ekle
if ! grep -q "CONFIG_BOEFFLA_WL_BLOCKER" "$KERNEL_DIR/drivers/misc/Makefile"; then
    echo "obj-\$(CONFIG_BOEFFLA_WL_BLOCKER) += boeffla_wl_blocker.o" >> "$KERNEL_DIR/drivers/misc/Makefile"
fi

# 4. drivers/misc/Kconfig dosyasına yapılandırma seçeneğini ekle
if ! grep -q "config BOEFFLA_WL_BLOCKER" "$KERNEL_DIR/drivers/misc/Kconfig"; then
    sed -i '/endmenu/i \
config BOEFFLA_WL_BLOCKER\
	bool "Boeffla Wakelock Blocker"\
	default y\
	help\
	  Enables Boeffla Wakelock Blocker to prevent unwanted wakelocks\
	  from holding deep sleep.\
' "$KERNEL_DIR/drivers/misc/Kconfig"
fi

# 5. drivers/base/power/wakeup.c dosyasını kancala (hook)
WAKEUP_C="$KERNEL_DIR/drivers/base/power/wakeup.c"
if [ -f "$WAKEUP_C" ]; then
    if ! grep -q "boeffla_wl_blocker.h" "$WAKEUP_C"; then
        sed -i '1i #include <linux/boeffla_wl_blocker.h>' "$WAKEUP_C"
    fi

    if ! grep -q "is_boeffla_wl_blocked" "$WAKEUP_C"; then
        # wakeup_source_activate içine kanca ekle
        sed -i '/static void wakeup_source_activate/ {
            n
            a\
	if (is_boeffla_wl_blocked(ws->name))\
		return;\

        }' "$WAKEUP_C"
    fi
fi

# 6. m51_defconfig dosyasına bayrağı yaz
if [ -f "$KERNEL_DIR/arch/arm64/configs/m51_defconfig" ]; then
    if ! grep -q "CONFIG_BOEFFLA_WL_BLOCKER" "$KERNEL_DIR/arch/arm64/configs/m51_defconfig"; then
        echo "CONFIG_BOEFFLA_WL_BLOCKER=y" >> "$KERNEL_DIR/arch/arm64/configs/m51_defconfig"
    fi
fi

echo "==> Boeffla Wakelock Blocker başarıyla entegre edildi!"
