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
CFOGP_OPTIM_CFLAGS  := -O2 -flto
CFOGP_OPTIM_LDFLAGS := -O2 -flto -fuse-linker-plugin

# Debugging flags
CFOGP_DEBUG_CFLAGS  := -ggdb3
CFOGP_DEBUG_LDFLAGS := -rdynamic

include $(PLATFORMDIR)/cfogp/common.mk

################################################################################
# Base rootfs module
################################################################################

# Disable default root password.
BASE_ROOTFS_ROOT_PASSWD :=

################################################################################
# btrace module
################################################################################

MODULES += btrace

################################################################################
# busybox module
################################################################################

BUSYBOX_CONFIG_FILES   := $(CONFIGDIR)/busybox.mk
BUSYBOX_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/busybox_devel.defconfig

define BUSYBOX_PLATFORM_HELP

::Customization::
  $$(CONFIGDIR)/busybox.mk may be used to override any Kconfig settings of
  Busybox\'s native build.

endef

################################################################################
# clui module
################################################################################

CLUI_CONFIG_FILES   := $(CONFIGDIR)/clui.mk
CLUI_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/clui_devel.defconfig

################################################################################
# elfutils module
################################################################################

MODULES += elfutils

################################################################################
# ethtool module
################################################################################

MODULES += ethtool

################################################################################
# kvstore module
################################################################################

KVSTORE_CONFIG_FILES   := $(CONFIGDIR)/kvstore.mk
KVSTORE_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/kvstore_devel.defconfig

################################################################################
# libdb module
#
# Enable full error messaging support.
################################################################################

LIBDB_TARGET_CONFIGURE_ARGS += --disable-stripped_messages

################################################################################
# linux kernel module
################################################################################

LINUX_CONFIG_FILES := $(CONFIGDIR)/linux.mk
LINUX_DEFCONFIG    := $(PLATFORMDIR)/cfogp/linux_devel.defconfig

# Override platform help message to include devel specific informations
define LINUX_PLATFORM_HELP

::Customization::
  $$(CONFIGDIR)/linux.mk may be used to override any Kconfig settings of
  Linux\'s native build.

endef

################################################################################
# mmc_utils module
################################################################################

MODULES += mmc_utils

################################################################################
# nlink module
################################################################################

NLINK_CONFIG_FILES   := $(CONFIGDIR)/nlink.mk
NLINK_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/nlink_devel.defconfig

################################################################################
# nwif module
################################################################################

NWIF_CONFIG_FILES   := $(CONFIGDIR)/nwif.mk
NWIF_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/nwif_devel.defconfig

################################################################################
# strace module
################################################################################

MODULES += strace

################################################################################
# burner module
################################################################################

MODULES += tidor_burner

################################################################################
# root initRamFS module
################################################################################

MODULES += tidor_initramfs

################################################################################
# utils module
################################################################################

UTILS_CONFIG_FILES   := $(CONFIGDIR)/utils.mk
UTILS_DEFCONFIG_FILE := $(PLATFORMDIR)/cfogp/utils_devel.defconfig

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
