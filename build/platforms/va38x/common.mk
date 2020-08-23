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

################################################################################
# Build definitions common to all VA38X platform flavours
################################################################################

MODULES :=

################################################################################
# e2fsprogs module
################################################################################

MODULES += e2fsprogs

E2FSPROGS_SRCDIR                := $(TOPDIR)/src/e2fsprogs
E2FSPROGS_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
E2FSPROGS_TARGET_PREFIX         :=
E2FSPROGS_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG \
                                  -I$(stagingdir)/usr/include
E2FSPROGS_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2 \
                                  -L$(stagingdir)/lib \
                                  -Wl,-rpath-link,$(stagingdir)/lib
E2FSPROGS_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                  $(call ifdef, \
                                         E2FSPROGS_TARGET_CFLAGS, \
                                         CFLAGS="$(E2FSPROGS_TARGET_CFLAGS)") \
                                  $(call ifdef, \
                                         E2FSPROGS_TARGET_LDFLAGS, \
                                         LDFLAGS="$(E2FSPROGS_TARGET_LDFLAGS)") \
                                  --prefix=$(E2FSPROGS_TARGET_PREFIX) \
                                  --enable-elf-shlibs \
                                  --disable-backtrace \
                                  --disable-imager \
                                  --disable-resizer \
                                  --disable-fsck \
                                  --disable-libuuid \
                                  --disable-libblkid \
                                  --disable-uuidd \
                                  --disable-nls \
                                  --disable-rpath \
                                  --disable-fuse2fs \
                                  --disable-debugfs \
                                  --disable-testio-debug \
                                  --enable-lto \
                                  --disable-e2initrd-helper

E2FSPROGS_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                  DESTDIR:=$(stagingdir)

################################################################################
# External glibc basic objects
################################################################################

MODULES += libc

LIBC_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
LIBC_SYSROOT_DIR   := $(XTCHAIN_SYSROOT)
LIBC_RUNTIME_DIR   := /lib/tls/v7l/neon/vfp

################################################################################
# External glibc cryptography library
################################################################################

MODULES += libcrypt

################################################################################
# External glibc math library
################################################################################

MODULES += libm

################################################################################
# External glibc dynamic linking library
################################################################################

MODULES += libdl

################################################################################
# External glibc utility library
################################################################################

MODULES += libutil

################################################################################
# External glibc network services library
################################################################################

MODULES += libnss

################################################################################
# External glibc Internet domain name resolution service library
################################################################################

MODULES += libresolv

################################################################################
# External glibc POSIX threading library
################################################################################

MODULES += libpthread

################################################################################
# External glibc POSIX realtime extension library
################################################################################

MODULES += librt

################################################################################
# zlib module
################################################################################

MODULES += zlib

ZLIB_SRCDIR        := $(TOPDIR)/src/zlib
ZLIB_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
ZLIB_CFLAGS        := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O3
ZLIB_LDFLAGS       := $(VA38X_LDFLAGS) -O3

################################################################################
# linux kernel module
################################################################################

MODULES += linux

LINUX_SRCDIR        := $(TOPDIR)/src/linux
LINUX_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
LINUX_ARCH          := arm
LINUX_DEVICETREE    := vexpress-v2p-ca9

################################################################################
# busybox module
################################################################################

MODULES += busybox

BUSYBOX_SRCDIR        := $(TOPDIR)/src/busybox
BUSYBOX_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
BUSYBOX_ARCH          := arm
BUSYBOX_CFLAGS        := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O2
BUSYBOX_LDFLAGS       := $(VA38X_LDFLAGS) -O2

################################################################################
# tinit module
################################################################################

MODULES += tinit

TINIT_SRCDIR        := $(TOPDIR)/src/tinit
TINIT_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
TINIT_CFLAGS        := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O2
TINIT_LDFLAGS       := $(VA38X_LDFLAGS) -O2

################################################################################
# Base rootfs module
################################################################################

MODULES += base_rootfs

# Define default root password.
BASE_ROOTFS_ROOT_PASSWD := superuser

################################################################################
# btrace module
################################################################################

MODULES += btrace

BTRACE_SRCDIR         := $(TOPDIR)/src/btrace
BTRACE_EBUILDDIR      := $(TOPDIR)/src/ebuild
BTRACE_CROSS_COMPILE  := $(XTCHAIN_CROSS_COMPILE)-
BTRACE_CFLAGS         := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) \
                         -O2 -DNDEBUG
BTRACE_LDFLAGS        := $(VA38X_LDFLAGS) -O2
BTRACE_PKGCONF        := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# IANA etc module
################################################################################

MODULES += iana_etc

IANA_ETC_SRCDIR := $(TOPDIR)/src/iana_etc

################################################################################
# kvstore module
################################################################################

MODULES += kvstore

KVSTORE_SRCDIR         := $(TOPDIR)/src/kvstore
KVSTORE_EBUILDDIR      := $(TOPDIR)/src/ebuild
KVSTORE_CROSS_COMPILE  := $(XTCHAIN_CROSS_COMPILE)-
KVSTORE_DEFCONFIG_FILE := $(PLATFORMDIR)/va38x/kvstore_devel.defconfig
KVSTORE_CFLAGS         := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O2
KVSTORE_LDFLAGS        := $(VA38X_LDFLAGS) -Wl,-rpath-link,$(stagingdir)/lib -O2
KVSTORE_PKGCONF        := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# libdb module
#
# TODO:
# * setup production builds configure options : --enable-stripped_messages
# * select BDB utilities to install for production/devel builds.
################################################################################

MODULES += libdb

LIBDB_SRCDIR                := $(TOPDIR)/src/libdb
LIBDB_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG
LIBDB_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2
LIBDB_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
LIBDB_TARGET_PREFIX         :=
LIBDB_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                $(call ifdef, \
                                       LIBDB_TARGET_CFLAGS, \
                                       CFLAGS="$(LIBDB_TARGET_CFLAGS)") \
                                $(call ifdef, \
                                       LIBDB_TARGET_LDFLAGS, \
                                       LDFLAGS="$(LIBDB_TARGET_LDFLAGS)") \
                                --prefix=$(LIBDB_TARGET_PREFIX) \
                                --disable-compression \
                                --disable-hash \
                                --disable-heap \
                                --disable-partition \
                                --disable-replication \
                                --disable-compat185 \
                                --disable-cxx \
                                --disable-debug \
                                --disable-dump185 \
                                --disable-java \
                                --disable-mingw \
                                --disable-sql \
                                --disable-sql_compat \
                                --disable-jdbc \
                                --disable-amalgamation \
                                --disable-sql_codegen \
                                --disable-stl \
                                --disable-tcl \
                                --disable-test \
                                --disable-localization \
                                --disable-dbm \
                                --disable-dtrace \
                                --disable-systemtap \
                                --enable-umrw \
                                --enable-shared \
                                --enable-static \
                                --with-cryptography=no \
                                --disable-perfmon-statistics

LIBDB_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                DESTDIR:=$(stagingdir)

################################################################################
# libmnl module
################################################################################

MODULES += libmnl

LIBMNL_SRCDIR                := $(TOPDIR)/src/libmnl
LIBMNL_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2
LIBMNL_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2
LIBMNL_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
LIBMNL_TARGET_PREFIX         :=
LIBMNL_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                $(call ifdef, \
                                       LIBMNL_TARGET_CFLAGS, \
                                       CFLAGS="$(LIBMNL_TARGET_CFLAGS)") \
                                $(call ifdef, \
                                       LIBMNL_TARGET_LDFLAGS, \
                                       LDFLAGS="$(LIBMNL_TARGET_LDFLAGS)") \
                                --prefix=$(LIBMNL_TARGET_PREFIX) \
                                --enable-static
LIBMNL_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                DESTDIR:=$(stagingdir)

################################################################################
# libtinfo (terminfo) module
################################################################################

MODULES += libtinfo

################################################################################
# utils module
################################################################################

MODULES += utils

UTILS_SRCDIR         := $(TOPDIR)/src/utils
UTILS_EBUILDDIR      := $(TOPDIR)/src/ebuild
UTILS_CROSS_COMPILE  := $(XTCHAIN_CROSS_COMPILE)-
UTILS_DEFCONFIG_FILE := $(PLATFORMDIR)/va38x/utils_devel.defconfig
UTILS_CFLAGS         := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O2
UTILS_LDFLAGS        := $(VA38X_LDFLAGS) -O2

################################################################################
# mtd_utils module
################################################################################

MODULES += mtd_utils

MTD_UTILS_SRCDIR                := $(TOPDIR)/src/mtd_utils
MTD_UTILS_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG
MTD_UTILS_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2 \
                                   -L$(stagingdir)/lib \
                                   -Wl,-rpath-link,$(stagingdir)/lib
MTD_UTILS_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
MTD_UTILS_TARGET_PREFIX         :=
MTD_UTILS_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                   $(call ifdef, \
                                          MTD_UTILS_TARGET_CFLAGS, \
                                          CFLAGS="$(MTD_UTILS_TARGET_CFLAGS)") \
                                   $(call ifdef, \
                                          MTD_UTILS_TARGET_LDFLAGS, \
                                          LDFLAGS="$(MTD_UTILS_TARGET_LDFLAGS)") \
                                   --prefix=$(MTD_UTILS_TARGET_PREFIX) \
                                   --disable-unit-tests \
                                   --enable-shared \
                                   --enable-static \
                                   --without-jffs \
                                   --without-ubifs \
                                   --with-xattr \
                                   --without-selinux \
                                   --without-lzo \
                                   --without-zstd \
                                   --without-crypto

MTD_UTILS_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                   DESTDIR:=$(stagingdir)

################################################################################
# ncurses module
################################################################################

MODULES += ncurses

NCURSES_SRCDIR                := $(TOPDIR)/src/ncurses
NCURSES_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
NCURSES_TARGET_PREFIX         :=
NCURSES_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG
NCURSES_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2
NCURSES_TERMS                 := linux,putty,vt100,xterm-mono
NCURSES_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        NCURSES_TARGET_CFLAGS, \
                                        CFLAGS="$(NCURSES_TARGET_CFLAGS)") \
                                 $(call ifdef, \
                                        NCURSES_TARGET_LDFLAGS, \
                                        LDFLAGS="$(NCURSES_TARGET_LDFLAGS)") \
                                 --prefix=$(NCURSES_TARGET_PREFIX) \
                                 --with-shared \
                                 --without-cxx \
                                 --without-cxx-binding \
                                 --without-ada \
                                 --without-manpages \
                                 --without-progs \
                                 --without-tack \
                                 --without-profile \
                                 --without-gpm \
                                 --disable-big-core \
                                 --disable-home-terminfo \
                                 --disable-root-environ \
                                 --disable-ext-funcs \
                                 --enable-sigwinch \
                                 --without-develop \
                                 --enable-overwrite \
                                 --enable-widec \
                                 --disable-ext-colors
NCURSES_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# nlink module
################################################################################

MODULES += nlink

NLINK_SRCDIR         := $(TOPDIR)/src/nlink
NLINK_EBUILDDIR      := $(TOPDIR)/src/ebuild
NLINK_CROSS_COMPILE  := $(XTCHAIN_CROSS_COMPILE)-
NLINK_DEFCONFIG_FILE := $(PLATFORMDIR)/va38x/nlink_devel.defconfig
NLINK_CFLAGS         := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O2
NLINK_LDFLAGS        := $(VA38X_LDFLAGS) -O2
NLINK_PKGCONF        := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# nwif module
################################################################################

MODULES += nwif

NWIF_SRCDIR         := $(TOPDIR)/src/nwif
NWIF_EBUILDDIR      := $(TOPDIR)/src/ebuild
NWIF_CROSS_COMPILE  := $(XTCHAIN_CROSS_COMPILE)-
NWIF_DEFCONFIG_FILE := $(PLATFORMDIR)/va38x/nwif_devel.defconfig
NWIF_CFLAGS         := --sysroot=$(XTCHAIN_SYSROOT) $(VA38X_CFLAGS) -O2
NWIF_LDFLAGS        := $(VA38X_LDFLAGS) -O2
NWIF_PKGCONF        := $(XTCHAIN_PKGCONF_ENV)

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

READLINE_SRCDIR                := $(TOPDIR)/src/readline
READLINE_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
READLINE_TARGET_PREFIX         :=
READLINE_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG
READLINE_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2 \
                                  -L$(stagingdir)/lib \
                                  -Wl,-rpath-link,$(stagingdir)/lib
READLINE_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                  $(call ifdef, \
                                         READLINE_TARGET_CFLAGS, \
                                         CFLAGS="$(READLINE_TARGET_CFLAGS)") \
                                  $(call ifdef, \
                                         READLINE_TARGET_LDFLAGS, \
                                         LDFLAGS="$(READLINE_TARGET_LDFLAGS)") \
                                  --prefix=$(READLINE_TARGET_PREFIX) \
                                  --enable-static \
                                  --enable-shared \
                                  bash_cv_must_reinstall_sighandlers=no \
                                  bash_cv_func_sigsetjmp=present \
                                  bash_cv_func_strcoll_broken=no \
                                  bash_cv_func_ctype_nonascii=no \
                                  bash_cv_wcwidth_broken=no
READLINE_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                  DESTDIR:=$(stagingdir)

################################################################################
# util_linux module
################################################################################

MODULES += util_linux

UTIL_LINUX_SRCDIR                := $(TOPDIR)/src/util_linux
UTIL_LINUX_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
UTIL_LINUX_TARGET_PREFIX         :=
UTIL_LINUX_TARGET_CFLAGS         := $(VA38X_CFLAGS) -O2 -DNDEBUG \
                                    -I$(stagingdir)/usr/include
UTIL_LINUX_TARGET_LDFLAGS        := $(VA38X_LDFLAGS) -O2 \
                                    -L$(stagingdir)/lib \
                                    -Wl,-rpath-link,$(stagingdir)/lib
UTIL_LINUX_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                    $(call ifdef, \
                                           UTIL_LINUX_TARGET_CFLAGS, \
                                           CFLAGS="$(UTIL_LINUX_TARGET_CFLAGS)") \
                                    $(call ifdef, \
                                           UTIL_LINUX_TARGET_LDFLAGS, \
                                           LDFLAGS="$(UTIL_LINUX_TARGET_LDFLAGS)") \
                                    NCURSESW6_CONFIG="$(stagingdir)/bin/ncursesw6-config" \
                                    --prefix=$(UTIL_LINUX_TARGET_PREFIX) \
                                    --enable-shared \
                                    --enable-static \
                                    --disable-gtk-doc \
                                    --disable-assert \
                                    --disable-nls \
                                    --disable-rpath \
                                    --enable-libuuid \
                                    --enable-libblkid \
                                    --enable-libmount \
                                    --enable-libsmartcols \
                                    --enable-libfdisk \
                                    --enable-fdisks \
                                    --enable-mount \
                                    --disable-zramctl \
                                    --enable-fsck \
                                    --disable-partx \
                                    --disable-uuidd \
                                    --disable-wipefs \
                                    --enable-mountpoint \
                                    --disable-fallocate \
                                    --disable-unshare \
                                    --disable-nsenter \
                                    --disable-setpriv \
                                    --disable-hardlink \
                                    --disable-eject \
                                    --disable-agetty \
                                    --disable-plymouth_support \
                                    --disable-cramfs \
                                    --disable-bfs \
                                    --disable-minix \
                                    --disable-fdformat \
                                    --disable-hwclock \
                                    --disable-hwclock-cmos \
                                    --disable-lslogins \
                                    --disable-wdctl \
                                    --disable-cal \
                                    --disable-logger \
                                    --disable-switch_root \
                                    --disable-pivot_root \
                                    --disable-lsmem \
                                    --disable-chmem \
                                    --disable-ipcrm \
                                    --disable-ipcs \
                                    --disable-rfkill \
                                    --disable-tunelp \
                                    --disable-kill \
                                    --disable-last \
                                    --disable-utmpdump \
                                    --disable-line \
                                    --disable-mesg \
                                    --disable-raw \
                                    --disable-rename \
                                    --disable-vipw \
                                    --disable-newgrp \
                                    --disable-chfn-chsh \
                                    --disable-login \
                                    --disable-nologin \
                                    --disable-sulogin \
                                    --disable-su \
                                    --disable-runuser \
                                    --disable-ul \
                                    --disable-more \
                                    --disable-pg \
                                    --disable-setterm \
                                    --disable-schedutils \
                                    --disable-wall \
                                    --disable-write \
                                    --disable-bash-completion \
                                    --disable-pylibmount \
                                    --disable-pg-bell \
                                    --enable-fs-paths-default=/sbin \
                                    --disable-sulogin-emergency-mount \
                                    --without-selinux \
                                    --without-audit \
                                    --without-udev \
                                    --without-slang \
                                    --with-tinfo \
                                    --with-readline \
                                    --without-utempter \
                                    --without-cap-ng \
                                    --with-libz \
                                    --without-user \
                                    --without-btrfs \
                                    --without-systemd \
                                    --with-smack \
                                    --without-python \
                                    --without-cryptsetup

UTIL_LINUX_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                  DESTDIR:=$(stagingdir)

################################################################################
# VA38X rootfs module
################################################################################

MODULES += va38x_rootfs

VA38X_ROOTFS_SRCDIR := $(TOPDIR)/src/va38x_rootfs

################################################################################
# VA38X root initRamFS module
################################################################################

MODULES += va38x_initramfs

################################################################################
# VA38X root squashFS module
################################################################################

MODULES += va38x_squashfs

# Disable compression an NFS export support.
VA38X_SQUASHFS_OPTS := -no-exports -noI -noD -noF -noX
