include $(PLATFORMDIR)/xtchain.mk

################################################################################
# Build definitions common to all tidor platforms
################################################################################

# Just to prevent from environment overriding
unexport AS \
         CPP \
         CPPFLAGS \
         CC \
         CFLAGS \
         CXX \
         CXXFLAGS \
         LD \
         LDFLAGS \
         AR \
         NM \
         RANLIB \
         OBJCOPY \
         OBJDUMP \
         STRIP \
         SHELL \
         ARCH \
         CROSS_COMPILE \
         CONFIG_PREFIX \
         LD_LIBRARY_PATH \
         LD_RUN_PATH

MODULES :=

# Hardware architecture specific flags
CFOGP_ARCH_CFLAGS := -mabi=aapcs-linux \
                     -mno-thumb-interwork \
                     -marm \
                     -march=armv7-a+mp+sec+simd \
                     -mtune=cortex-a9 \
                     -mcpu=cortex-a9 \
                     -mfpu=neon-vfpv3 \
                     -mhard-float \
                     -mfloat-abi=hard

CFOGP_CFLAGS      := $(CFOGP_ARCH_CFLAGS) \
                     $(CFOGP_HARDEN_CFLAGS) \
                     $(CFOGP_OPTIM_CFLAGS) \
                     $(CFOGP_DEBUG_CFLAGS)

CFOGP_LDFLAGS     := $(strip $(CFOGP_HARDEN_LDLAGS) \
                             $(CFOGP_OPTIM_LDFLAGS) \
                             $(CFOGP_DEBUG_LDFLAGS))

################################################################################
# Base rootfs module
################################################################################

MODULES += base_rootfs

# Default root password.
BASE_ROOTFS_ROOT_PASSWD := superuser

################################################################################
# btrace module
################################################################################

BTRACE_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
BTRACE_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# busybox module
################################################################################

MODULES += busybox

BUSYBOX_ARCH    := arm
BUSYBOX_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) \
                   $(filter-out -O%,$(CFOGP_CFLAGS))
BUSYBOX_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# clui module
################################################################################

MODULES += clui

CLUI_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
CLUI_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# e2fsprogs module
################################################################################

MODULES += e2fsprogs

E2FSPROGS_TARGET_CFLAGS  := $(CFOGP_CFLAGS) -I$(stagingdir)/usr/include
E2FSPROGS_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                            -L$(stagingdir)/lib \
                            -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# elfutils module
################################################################################

ELFUTILS_TARGET_CFLAGS  := $(CFOGP_CFLAGS) -I$(stagingdir)/usr/include
ELFUTILS_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                           -L$(stagingdir)/lib \
                           -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# ethtool module
################################################################################

ETHTOOL_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
ETHTOOL_TARGET_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# IANA etc module
################################################################################

MODULES += iana_etc

################################################################################
# kvstore module
################################################################################

MODULES += kvstore

KVSTORE_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
KVSTORE_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# External glibc modules
################################################################################

# Basic glibc
MODULES += libc

LIBC_RUNTIME_DIR := /lib/tls/v7l/neon/vfp

# glibc crypto library
MODULES += libcrypt
# glibc dynamic linking library
MODULES += libdl
# glibc math library
MODULES += libm
# glibc network services library
MODULES += libnss
# glibc POSIX threading library
MODULES += libpthread
# glibc Internet domain name resolution service library
MODULES += libresolv
# glibc POSIX realtime extension library
MODULES += librt
# glibc utility library
MODULES += libutil

################################################################################
# libdb module
#
# TODO: see $(PLATFORMDIR)/tidor/common.mk, module libdb
################################################################################

MODULES += libdb

LIBDB_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
LIBDB_TARGET_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# libmnl module
################################################################################

MODULES += libmnl

LIBMNL_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
LIBMNL_TARGET_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# libtinfo (terminfo) module shipped with ncurses
################################################################################

MODULES += libtinfo

################################################################################
# linux kernel module
################################################################################

MODULES += linux

LINUX_ARCH       := arm
LINUX_DEVICETREE := armada-388-clearfog-pro

################################################################################
# mmc_utils module
################################################################################

MMC_UTILS_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
MMC_UTILS_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# mtd_utils module
################################################################################

MODULES += mtd_utils

MTD_UTILS_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
MTD_UTILS_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                            -L$(stagingdir)/lib \
                            -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# ncurses module
################################################################################

MODULES += ncurses

NCURSES_TERMS          := linux,putty,vt100,xterm-mono
NCURSES_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
NCURSES_TARGET_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# nlink module
################################################################################

MODULES += nlink

NLINK_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
NLINK_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# nwif module
################################################################################

MODULES += nwif

NWIF_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
NWIF_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# readline module
#
# To overcome Autotools limitations due to cross-compiling process, the
# options below are given to configure to override failing auto-detect results.
# These are toolchain / OS / platform specific:
# - bash_cv_must_reinstall_sighandlers=no
# - bash_cv_func_sigsetjmp=present
# - bash_cv_func_strcoll_broken=no
# - bash_cv_func_ctype_nonascii=no
# - bash_cv_wcwidth_broken=no
################################################################################

MODULES += readline

READLINE_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
READLINE_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                           -L$(stagingdir)/lib \
                           -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# strace module
################################################################################

STRACE_TARGET_CFLAGS  := $(CFOGP_CFLAGS)
STRACE_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                         -L$(stagingdir)/lib \
                         -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# rootfs module
################################################################################

MODULES += tidor_rootfs

################################################################################
# root squashFS module
################################################################################

MODULES += tidor_squashfs

# Disable compression and NFS export support.
TIDOR_SQUASHFS_OPTS := -no-exports -noI -noD -noF -noX

################################################################################
# tinit module
################################################################################

MODULES += tinit

TINIT_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
TINIT_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# util_linux module
################################################################################

MODULES += util_linux

UTIL_LINUX_TARGET_CFLAGS  := $(CFOGP_CFLAGS) -I$(stagingdir)/usr/include
UTIL_LINUX_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                             -L$(stagingdir)/lib \
                             -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# utils module
################################################################################

MODULES += utils

UTILS_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(CFOGP_CFLAGS)
UTILS_LDFLAGS := $(CFOGP_LDFLAGS)

################################################################################
# zlib module
################################################################################

MODULES += zlib

ZLIB_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) \
                $(CFOGP_ARCH_CFLAGS) \
                $(CFOGP_HARDEN_CFLAGS) \
                -O3 -DNDEBUG -flto \
                $(CFOGP_DEBUG_CFLAGS)
ZLIB_LDFLAGS := $(CFOGP_HARDEN_LDLAGS) \
                -O3 -flto -fuse-linker-plugin \
                $(CFOGP_DEBUG_LDFLAGS)
