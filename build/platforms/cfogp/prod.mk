# Security hardening flags
#CFOGP_HARDEN_CFLAGS := -D_FORTIFY_SOURCE=2 \
#                       -fstack-protector-all \
#                       -fstack-check \
#                       -fstack-clash-protection \
#                       -fsanitize=address \
#                       -fsanitize=pointer-compare \
#                       -fsanitize=pointer-subtract \
#                       -fsanitize=leak \
#                       -fsanitize=undefined \
#                       -fsanitize-address-use-after-scope \
#                       -fcf-protection=full
#                       -fpie / -fPIE -DPIE
#CFOGP_HARDEN_LDFLAGS := -pie \
#                        -Wl,-z,relro -Wl,-z,now

# Optimization flags
CFOGP_OPTIM_CFLAGS  := -O2 -flto -DNDEBUG
CFOGP_OPTIM_LDFLAGS := -O2 -flto -fuse-linker-plugin

# Debugging flags
CFOGP_DEBUG_CFLAGS  := -ggdb3
CFOGP_DEBUG_LDFLAGS :=

include $(PLATFORMDIR)/cfogp/common.mk

################################################################################
# busybox module
################################################################################

BUSYBOX_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/busybox_prod.defconfig

################################################################################
# clui module
################################################################################

CLUI_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/clui_prod.defconfig

################################################################################
# kvstore module
################################################################################

KVSTORE_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/kvstore_prod.defconfig

################################################################################
# linux kernel module
################################################################################

LINUX_DEFCONFIG := $(PLATFORMDIR)/cfogp/linux_prod.defconfig

################################################################################
# nlink module
################################################################################

NLINK_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/nlink_prod.defconfig

################################################################################
# nwif module
################################################################################

NWIF_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/nwif_prod.defconfig

################################################################################
# utils module
################################################################################

UTILS_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/utils_prod.defconfig

################################################################################
# Final module
################################################################################

#MODULES += a38x_snor

# Declare path to Marvell Kirwood / Armada CPU bootROM binary
#CFOGP_SNOR_BOOTROM_PATH := a_path_to_marvell_bootrom.bin

# Declare path to U-Boot compliant Flat Image Tree boot specification
#CFOGP_SNOR_ITS_PATH := $(PLATFORMDIR)/a38x_snor/a38x_snor.its

################################################################################
# Finally include tidor related global definitions
# Keep this last as it depends on the above definitions !!
################################################################################

include $(PLATFORMDIR)/tidor/system.mk
