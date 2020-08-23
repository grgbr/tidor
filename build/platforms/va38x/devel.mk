# Debugging flags
VA38X_DEBUG_CFLAGS  := -ggdb3
VA38X_DEBUG_LDFLAGS := -rdynamic

# Security hardening flags
#VA38X_HARDEN_CFLAGS := -D_FORTIFY_SOURCE=2 \
#                       -fstack-protector-all
#                       -fstack-check
#

# Hardware architecture specific flags
VA38X_ARCH_CFLAGS := -mabi=aapcs-linux \
                     -mno-thumb-interwork \
                     -marm \
                     -march=armv7-a+mp+sec+simd \
                     -mtune=cortex-a9 \
                     -mcpu=cortex-a9 \
                     -mfpu=neon-vfpv3 \
                     -mhard-float \
                     -mfloat-abi=hard

VA38X_CFLAGS  := $(VA38X_ARCH_CFLAGS) \
                 $(VA38X_HARDEN_CFLAGS) \
                 $(VA38X_DEBUG_CFLAGS)
VA38X_LDFLAGS := $(VA38X_DEBUG_LDFLAGS)

include $(PLATFORMDIR)/va38x/common.mk

################################################################################
# Base rootfs module
################################################################################

# Override default root password.
BASE_ROOTFS_ROOT_PASSWD :=

################################################################################
# busybox module
################################################################################

# Declare additional busybox configuration files to be merged with default
# board build configuration.
BUSYBOX_CONFIG_FILES := $(CONFIGDIR)/busybox.mk

# Use development oriented build configuration.
BUSYBOX_DEFCONFIG_FILE := $(PLATFORMDIR)/va38x/busybox_devel.defconfig

# Override platform help message to include devel specific informations
define BUSYBOX_PLATFORM_HELP

::Customization::
  $$(CONFIGDIR)/busybox.mk may be used to override any Kconfig settings of
  Busybox\'s native build.

endef

################################################################################
# elfutils module
################################################################################

MODULES += elfutils

ELFUTILS_SRCDIR                := $(TOPDIR)/src/elfutils
ELFUTILS_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
ELFUTILS_TARGET_PREFIX         :=
ELFUTILS_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 \
                                  -I$(stagingdir)/usr/include
ELFUTILS_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2 \
                                  -L$(stagingdir)/lib \
                                  -Wl,-rpath-link,$(stagingdir)/lib
ELFUTILS_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                  $(call ifdef, \
                                         ELFUTILS_TARGET_CFLAGS, \
                                         CFLAGS="$(ELFUTILS_TARGET_CFLAGS)") \
                                  $(call ifdef, \
                                         ELFUTILS_TARGET_LDFLAGS, \
                                         LDFLAGS="$(ELFUTILS_TARGET_LDFLAGS)") \
                                  --prefix=$(ELFUTILS_TARGET_PREFIX) \
                                  --disable-nls \
                                  --disable-debuginfod
ELFUTILS_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                  DESTDIR:=$(stagingdir)

################################################################################
# ethtool module
################################################################################

MODULES += ethtool

ETHTOOL_SRCDIR                := $(TOPDIR)/src/ethtool
ETHTOOL_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG
ETHTOOL_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2
ETHTOOL_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
ETHTOOL_TARGET_PREFIX         :=
ETHTOOL_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        ETHTOOL_TARGET_CFLAGS, \
                                        CFLAGS="$(ETHTOOL_TARGET_CFLAGS)") \
                                 $(call ifdef, \
                                        ETHTOOL_TARGET_LDFLAGS, \
                                        LDFLAGS="$(ETHTOOL_TARGET_LDFLAGS)") \
                                 --prefix=$(ETHTOOL_TARGET_PREFIX) \
                                 --enable-pretty-dump
ETHTOOL_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# linux kernel module
################################################################################

# Declare additional Linux kernel configuration files to be merged with default
# board build configuration.
LINUX_CONFIG_FILES += $(CONFIGDIR)/linux.mk
LINUX_DEFCONFIG    := $(PLATFORMDIR)/va38x/linux_devel.defconfig

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

MMC_UTILS_SRCDIR        := $(TOPDIR)/src/mmc_utils
MMC_UTILS_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
MMC_UTILS_CFLAGS        := --sysroot=$(XTCHAIN_SYSROOT) \
                           $(VA38X_CFLAGS) -O2 -DNDEBUG
MMC_UTILS_LDFLAGS       := $(VA38X_LDFLAGS) -O2

################################################################################
# strace module
################################################################################

MODULES += strace

STRACE_SRCDIR                := $(TOPDIR)/src/strace
STRACE_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
STRACE_TARGET_PREFIX         :=
STRACE_TARGET_CPPFLAGS       := -isystem $(stagingdir)/usr/include
STRACE_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2
STRACE_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2 \
                                -L$(stagingdir)/lib \
                                -Wl,-rpath-link,$(stagingdir)/lib
STRACE_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                $(call ifdef, \
                                       STRACE_TARGET_CPPFLAGS, \
                                       CPPFLAGS="$(STRACE_TARGET_CPPFLAGS)") \
                                $(call ifdef, \
                                       STRACE_TARGET_CFLAGS, \
                                       CFLAGS="$(STRACE_TARGET_CFLAGS)") \
                                $(call ifdef, \
                                       STRACE_TARGET_LDFLAGS, \
                                       LDFLAGS="$(STRACE_TARGET_LDFLAGS)") \
                                --prefix=$(STRACE_TARGET_PREFIX) \
                                --enable-stacktrace=yes \
                                --enable-mpers=no \
                                --with-libdw
STRACE_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                DESTDIR:=$(stagingdir)

################################################################################
# libdb module
#
# Enable full error messaging support.
################################################################################

LIBDB_TARGET_CONFIGURE_ARGS += --disable-stripped_messages

################################################################################
# Final module
################################################################################

#MODULES += a38x_snor

# Declare path to Marvell Kirwood / Armada CPU bootROM binary
#VA38X_SNOR_BOOTROM_PATH := a_path_to_marvell_bootrom.bin

# Declare path to U-Boot compliant Flat Image Tree boot specification
#VA38X_SNOR_ITS_PATH := $(PLATFORMDIR)/a38x_snor/a38x_snor.its
