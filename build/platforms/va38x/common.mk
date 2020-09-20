include $(PLATFORMDIR)/xtchain.mk

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
VA38X_ARCH_CFLAGS := -mabi=aapcs-linux \
                     -mno-thumb-interwork \
                     -marm \
                     -march=armv7-a+mp+sec+simd \
                     -mtune=cortex-a9 \
                     -mcpu=cortex-a9 \
                     -mfpu=neon-vfpv3 \
                     -mhard-float \
                     -mfloat-abi=hard

VA38X_CFLAGS      := $(VA38X_ARCH_CFLAGS) \
                     $(VA38X_HARDEN_CFLAGS) \
                     $(VA38X_OPTIM_CFLAGS) \
                     $(VA38X_DEBUG_CFLAGS)

VA38X_LDFLAGS     := $(strip $(VA38X_HARDEN_LDLAGS) \
                             $(VA38X_OPTIM_LDFLAGS) \
                             $(VA38X_DEBUG_LDFLAGS))

################################################################################
# Base rootfs module
################################################################################

MODULES += base_rootfs

# Define default root password.
BASE_ROOTFS_ROOT_PASSWD := superuser

################################################################################
# btrace module
################################################################################

BTRACE_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
BTRACE_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# busybox module
################################################################################

MODULES += busybox

BUSYBOX_ARCH    := arm
BUSYBOX_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) \
                   $(filter-out -O%,$(VA38X_CFLAGS))
BUSYBOX_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# clui module
################################################################################

MODULES += clui

CLUI_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
CLUI_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# e2fsprogs module
################################################################################

MODULES += e2fsprogs

E2FSPROGS_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
E2FSPROGS_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                            -L$(stagingdir)/lib \
                            -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# elfutils module
################################################################################

ELFUTILS_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
ELFUTILS_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                           -L$(stagingdir)/lib \
                           -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# ethtool module
################################################################################

ETHTOOL_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
ETHTOOL_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                          -L$(stagingdir)/lib \
                          -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# IANA etc module
################################################################################

MODULES += iana_etc

################################################################################
# iperf module
################################################################################

IPERF_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
IPERF_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                        -L$(stagingdir)/lib \
                        -Wl,-rpath-link,$(stagingdir)/lib
################################################################################
# iproute2 module
################################################################################

IPROUTE2_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
IPROUTE2_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                           -L$(stagingdir)/lib \
                           -Wl,-rpath-link,$(stagingdir)/lib


################################################################################
# root initRamFS module
################################################################################

MODULES += initramfs

################################################################################
# kvstore module
################################################################################

MODULES += kvstore

KVSTORE_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
KVSTORE_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# External glibc basic objects
################################################################################

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
# libcap module
################################################################################

LIBCAP_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
LIBCAP_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                         -L$(stagingdir)/lib \
                         -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# libdb module
#
# TODO: see $(PLATFORMDIR)/tidor/common.mk, module libdb
################################################################################

MODULES += libdb

LIBDB_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
LIBDB_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                        -L$(stagingdir)/lib \
                        -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# libmnl module
################################################################################

MODULES += libmnl

LIBMNL_TARGET_CFLAGS  := $(CFOGP_CFLAGS) -I$(stagingdir)/usr/include
LIBMNL_TARGET_LDFLAGS := $(CFOGP_LDFLAGS) \
                         -L$(stagingdir)/lib \
                         -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# libpcap module
################################################################################

LIBPCAP_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
LIBPCAP_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                          -L$(stagingdir)/lib \
                          -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# libtinfo (terminfo) module shipped with ncurses
################################################################################

MODULES += libtinfo

################################################################################
# linux kernel module
################################################################################

MODULES += linux

LINUX_ARCH       := arm
LINUX_DEVICETREE := vexpress-v2p-ca9

################################################################################
# mmc_utils module
################################################################################

MMC_UTILS_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
MMC_UTILS_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# mtd_utils module
################################################################################

MODULES += mtd_utils

MTD_UTILS_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
MTD_UTILS_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                            -L$(stagingdir)/lib \
                            -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# ncurses module
################################################################################

MODULES += ncurses

NCURSES_TERMS          := linux,putty,vt100,xterm-mono
NCURSES_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
NCURSES_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                          -L$(stagingdir)/lib \
                          -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# netperf module
################################################################################

NETPERF_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
NETPERF_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                          -L$(stagingdir)/lib \
                          -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# nlink module
################################################################################

MODULES += nlink

NLINK_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
NLINK_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# nwif module
################################################################################

MODULES += nwif

NWIF_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
NWIF_LDFLAGS := $(VA38X_LDFLAGS)

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

READLINE_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
READLINE_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                           -L$(stagingdir)/lib \
                           -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# root squashFS module
################################################################################

MODULES += root_squashfs

################################################################################
# strace module
################################################################################

STRACE_TARGET_CFLAGS  := $(VA38X_CFLAGS)
STRACE_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                         -L$(stagingdir)/lib \
                         -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# TiDor rootfs module
################################################################################

MODULES += tidor_rootfs

################################################################################
# tinit module
################################################################################

MODULES += tinit

TINIT_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
TINIT_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# util_linux module
################################################################################

MODULES += util_linux

UTIL_LINUX_TARGET_CFLAGS  := $(VA38X_CFLAGS) -I$(stagingdir)/usr/include
UTIL_LINUX_TARGET_LDFLAGS := $(VA38X_LDFLAGS) \
                             -L$(stagingdir)/lib \
                             -Wl,-rpath-link,$(stagingdir)/lib

################################################################################
# utils module
################################################################################

MODULES += utils

UTILS_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS)
UTILS_LDFLAGS := $(VA38X_LDFLAGS)

################################################################################
# zlib module
################################################################################

MODULES += zlib

ZLIB_CFLAGS  := --sysroot=$(XTCHAIN_SYSROOT) \
                $(VA38X_ARCH_CFLAGS) \
                $(VA38X_HARDEN_CFLAGS) \
                -O3 -DNDEBUG -flto \
                $(VA38X_DEBUG_CFLAGS)
ZLIB_LDFLAGS := $(VA38X_HARDEN_LDLAGS) \
                -O3 -flto -fuse-linker-plugin \
                $(VA38X_DEBUG_LDFLAGS)
