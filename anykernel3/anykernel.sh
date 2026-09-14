### AnyKernel3 Workspace
# begin properties
properties() { '
kernel.string=SesKernel for Samsung Galaxy M51 (SM7150)
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=m51
device.name2=m51nxx
device.name3=m51xxx
device.name4=SM-M515F
device.name5=M515F
supported.versions=11, 12, 12.1, 13, 14, 15
supported.patchlevels=
'; } # end properties

### AnyKernel setup
# begin-setup
ui_print " ";
ui_print "*********************************************";
ui_print "*               SesKernel                   *";
ui_print "*       Samsung Galaxy M51 (SM7150)         *";
ui_print "*   KernelSU + WireGuard + Boeffla + zRAM   *";
ui_print "*********************************************";

BLOCK=boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

## AnyKernel methods (DO NOT CHANGE)
# set up permissions/variables
. tools/ak3-core.sh;

## AnyKernel boot install
dump_boot;

write_boot;
## end boot install

## AnyKernel dtbo install
flash_dtbo;
## end dtbo install
