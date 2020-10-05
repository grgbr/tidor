################################################################################
# btrace module
################################################################################

BTRACE_SRCDIR        := $(TOPDIR)/src/btrace
BTRACE_EBUILDDIR     := $(TOPDIR)/src/ebuild
BTRACE_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
BTRACE_PKGCONF       := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# busybox module
################################################################################

BUSYBOX_SRCDIR        := $(TOPDIR)/src/busybox
BUSYBOX_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-

################################################################################
# clui module
################################################################################

CLUI_SRCDIR        := $(TOPDIR)/src/clui
CLUI_EBUILDDIR     := $(TOPDIR)/src/ebuild
CLUI_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
CLUI_PKGCONF       := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# cryptodev Linux kernel external module
################################################################################

CRYPTODEV_SRCDIR      := $(TOPDIR)/src/cryptodev-linux
CRYPTODEV_TARGET_ARGS := PATH="$(XTCHAIN_PATH)" \
                         CRYPTODEV_CFLAGS:="-DENABLE_ASYNC"

################################################################################
# e2fsprogs module
################################################################################

E2FSPROGS_SRCDIR                := $(TOPDIR)/src/e2fsprogs
E2FSPROGS_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
E2FSPROGS_TARGET_PREFIX         :=
E2FSPROGS_TARGET_CONFIGURE_ARGS := \
	$(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
	$(call ifdef, \
	       E2FSPROGS_TARGET_CFLAGS, \
               CFLAGS="$(E2FSPROGS_TARGET_CFLAGS)") \
	$(call ifdef, \
	       E2FSPROGS_TARGET_LDFLAGS, \
	       LDFLAGS="$(E2FSPROGS_TARGET_LDFLAGS)") \
	--prefix="$(E2FSPROGS_TARGET_PREFIX)" \
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
# elfutils module
#
# Note: as of 0.179, elfutils fail to build with lto enabled.
################################################################################

ELFUTILS_SRCDIR                := $(TOPDIR)/src/elfutils
ELFUTILS_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
ELFUTILS_TARGET_PREFIX         :=
ELFUTILS_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                  $(call ifdef, \
                                         ELFUTILS_TARGET_CFLAGS, \
                                         CFLAGS="$(filter-out -flto, \
                                                   $(ELFUTILS_TARGET_CFLAGS))") \
                                  $(call ifdef, \
                                         ELFUTILS_TARGET_LDFLAGS, \
                                         LDFLAGS="$(filter-out -flto, \
                                                    $(ELFUTILS_TARGET_LDFLAGS))") \
                                  --prefix="$(ELFUTILS_TARGET_PREFIX)" \
                                  --disable-nls \
                                  --disable-debuginfod
ELFUTILS_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                  DESTDIR:=$(stagingdir)

################################################################################
# ethtool module
################################################################################

ETHTOOL_SRCDIR                := $(TOPDIR)/src/ethtool
ETHTOOL_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
ETHTOOL_TARGET_PREFIX         :=
ETHTOOL_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        ETHTOOL_TARGET_CFLAGS, \
                                        CFLAGS="$(ETHTOOL_TARGET_CFLAGS)") \
                                 $(call ifdef, \
                                        ETHTOOL_TARGET_LDFLAGS, \
                                        LDFLAGS="$(ETHTOOL_TARGET_LDFLAGS)") \
                                 --prefix="$(ETHTOOL_TARGET_PREFIX)" \
                                 --enable-pretty-dump
ETHTOOL_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# rng_tools module
################################################################################

HAVEGED_SRCDIR                := $(TOPDIR)/src/haveged
HAVEGED_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
HAVEGED_TARGET_PREFIX         :=
HAVEGED_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        HAVEGED_TARGET_CFLAGS, \
                                        CFLAGS="$(HAVEGED_TARGET_CFLAGS)") \
                                 $(call ifdef, \
                                        HAVEGED_TARGET_LDFLAGS, \
                                        LDFLAGS="$(HAVEGED_TARGET_LDFLAGS)") \
                                 --prefix="$(HAVEGED_TARGET_PREFIX)" \
                                 --enable-daemon \
                                 --enable-init=no \
                                 --enable-tune=no
HAVEGED_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# IANA etc module
################################################################################

IANA_ETC_SRCDIR := $(TOPDIR)/src/iana_etc

################################################################################
# root InitRamFS module
################################################################################

INITRAMFS_DEPENDS := tidor_rootfs

################################################################################
# iperf module
################################################################################

IPERF_SRCDIR                := $(TOPDIR)/src/iperf
IPERF_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
IPERF_TARGET_PREFIX         :=
IPERF_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                               $(call ifdef, \
                                      IPERF_TARGET_CFLAGS, \
                                      CFLAGS="$(IPERF_TARGET_CFLAGS)") \
                               $(call ifdef, \
                                      IPERF_TARGET_LDFLAGS, \
                                      LDFLAGS="$(IPERF_TARGET_LDFLAGS)") \
                               --prefix="$(IPERF_TARGET_PREFIX)" \
                               --without-sctp
IPERF_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                               DESTDIR:=$(stagingdir)

################################################################################
# iproute2 module
################################################################################

IPROUTE2_SRCDIR        := $(TOPDIR)/src/iproute2
IPROUTE2_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
IPROUTE2_TARGET_ARGS   := PATH="$(XTCHAIN_PATH)" \
                          $(XTCHAIN_PKGCONF_ENV)

################################################################################
# kvstore module
################################################################################

KVSTORE_SRCDIR        := $(TOPDIR)/src/kvstore
KVSTORE_EBUILDDIR     := $(TOPDIR)/src/ebuild
KVSTORE_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
KVSTORE_PKGCONF       := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# libcap module
################################################################################

LIBCAP_SRCDIR           := $(TOPDIR)/src/libcap

LIBCAP_CROSS_COMPILE    := $(XTCHAIN_CROSS_COMPILE)-
LIBCAP_TARGET_MAKE_ARGS := PATH:="$(XTCHAIN_PATH)" \
                           $(XTCHAIN_PKGCONF_ENV) \
                           PAM_CAP:=no \
                           GOLANG:=no

################################################################################
# External glibc basic objects
################################################################################

LIBC_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
LIBC_SYSROOT_DIR   := $(XTCHAIN_SYSROOT)

################################################################################
# libdb module
#
# TODO:
# * setup production builds configure options : --enable-stripped_messages
# * select BDB utilities to install for production/devel builds.
################################################################################

LIBDB_SRCDIR                := $(TOPDIR)/src/libdb
LIBDB_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
LIBDB_TARGET_PREFIX         :=
LIBDB_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                               $(call ifdef, \
                                      LIBDB_TARGET_CFLAGS, \
                                      CFLAGS="$(LIBDB_TARGET_CFLAGS)") \
                               $(call ifdef, \
                                      LIBDB_TARGET_LDFLAGS, \
                                      LDFLAGS="$(LIBDB_TARGET_LDFLAGS)") \
                               --prefix="$(LIBDB_TARGET_PREFIX)" \
                               --disable-compression \
                               --disable-hash \
                               --enable-heap \
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

LIBMNL_SRCDIR                := $(TOPDIR)/src/libmnl
LIBMNL_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
LIBMNL_TARGET_PREFIX         :=
LIBMNL_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                $(call ifdef, \
                                       LIBMNL_TARGET_CFLAGS, \
                                       CFLAGS="$(LIBMNL_TARGET_CFLAGS)") \
                                $(call ifdef, \
                                       LIBMNL_TARGET_LDFLAGS, \
                                       LDFLAGS="$(LIBMNL_TARGET_LDFLAGS)") \
                                --prefix="$(LIBMNL_TARGET_PREFIX)" \
                                --enable-static
LIBMNL_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                DESTDIR:=$(stagingdir)

################################################################################
# libpcap module
################################################################################

LIBPCAP_SRCDIR                := $(TOPDIR)/src/libpcap
LIBPCAP_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
LIBPCAP_TARGET_PREFIX         :=
LIBPCAP_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        LIBPCAP_TARGET_CFLAGS, \
                                        CFLAGS="$(LIBPCAP_TARGET_CFLAGS)") \
                                 $(call ifdef, \
                                        LIBPCAP_TARGET_LDFLAGS, \
                                        LDFLAGS="$(LIBPCAP_TARGET_LDFLAGS)") \
                                 --prefix="$(LIBPCAP_TARGET_PREFIX)" \
                                 --disable-ipv6 \
                                 --disable-remote \
                                 --disable-universal \
                                 --enable-shared \
                                 --disable-usb \
                                 --disable-bluetooth \
                                 --disable-dbus \
                                 --disable-rdma \
                                 --without-libnl
LIBPCAP_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# libuv module
################################################################################

LIBUV_SRCDIR                := $(TOPDIR)/src/libuv
LIBUV_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
LIBUV_TARGET_PREFIX         :=
LIBUV_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                               $(call ifdef, \
                                      LIBUV_TARGET_CFLAGS, \
                                      CFLAGS="$(LIBUV_TARGET_CFLAGS)") \
                               $(call ifdef, \
                                      LIBUV_TARGET_LDFLAGS, \
                                      LDFLAGS="$(LIBUV_TARGET_LDFLAGS)") \
                               --prefix="$(LIBUV_TARGET_PREFIX)"
LIBUV_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                               DESTDIR:=$(stagingdir)

################################################################################
# linux kernel module
################################################################################

LINUX_SRCDIR        := $(TOPDIR)/src/linux
LINUX_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-

################################################################################
# mmc_utils module
################################################################################

MMC_UTILS_SRCDIR        := $(TOPDIR)/src/mmc_utils
MMC_UTILS_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-

################################################################################
# mtd_utils module
################################################################################

MTD_UTILS_SRCDIR                := $(TOPDIR)/src/mtd_utils
MTD_UTILS_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
MTD_UTILS_TARGET_PREFIX         :=
MTD_UTILS_TARGET_CONFIGURE_ARGS := \
	$(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
	$(call ifdef, \
	       MTD_UTILS_TARGET_CFLAGS, \
	       CFLAGS="$(MTD_UTILS_TARGET_CFLAGS)") \
	$(call ifdef, \
	       MTD_UTILS_TARGET_LDFLAGS, \
	       LDFLAGS="$(MTD_UTILS_TARGET_LDFLAGS)") \
	--prefix="$(MTD_UTILS_TARGET_PREFIX)" \
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

NCURSES_SRCDIR                := $(TOPDIR)/src/ncurses
NCURSES_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
NCURSES_TARGET_PREFIX         :=
NCURSES_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        NCURSES_TARGET_CFLAGS, \
                                        CFLAGS="$(NCURSES_TARGET_CFLAGS)") \
                                 $(call ifdef, \
                                        NCURSES_TARGET_LDFLAGS, \
                                        LDFLAGS="$(NCURSES_TARGET_LDFLAGS)") \
                                 --prefix="$(NCURSES_TARGET_PREFIX)" \
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
                                 --disable-ext-colors \
                                 ac_cv_func_issetugid='no'
NCURSES_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# netperf module
################################################################################

NETPERF_SRCDIR                := $(TOPDIR)/src/netperf
NETPERF_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
NETPERF_TARGET_PREFIX         :=
NETPERF_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                 $(call ifdef, \
                                        NETPERF_TARGET_CFLAGS, \
                                        CFLAGS="$(NETPERF_TARGET_CFLAGS)") \
                                $(call ifdef, \
                                       NETPERF_TARGET_LDFLAGS, \
                                       LDFLAGS="$(NETPERF_TARGET_LDFLAGS)") \
                                --prefix="$(NETPERF_TARGET_PREFIX)" \
                                --enable-unixdomain \
                                --disable-dlpi \
                                --disable-dccp \
                                --enable-omni \
                                --disable-xti \
                                --disable-sdp \
                                --disable-exs \
                                --disable-sctp \
                                --enable-intervals \
                                --enable-spin \
                                --enable-burst \
                                --enable-cpuutil=procstat \
                                ac_cv_func_setpgrp_void=yes
NETPERF_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                 DESTDIR:=$(stagingdir)

################################################################################
# nlink module
################################################################################

NLINK_SRCDIR        := $(TOPDIR)/src/nlink
NLINK_EBUILDDIR     := $(TOPDIR)/src/ebuild
NLINK_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
NLINK_PKGCONF       := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# nwif module
################################################################################

NWIF_SRCDIR        := $(TOPDIR)/src/nwif
NWIF_EBUILDDIR     := $(TOPDIR)/src/ebuild
NWIF_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
NWIF_PKGCONF       := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# openssl module
# TODO: see openssl/INSTALL:
# --with-rand-seed
################################################################################

OPENSSL_SRCDIR                := $(TOPDIR)/src/openssl
OPENSSL_CROSS_COMPILE         := $(XTCHAIN_CROSS_COMPILE)-
OPENSSL_TARGET_CONFIGURE_ARGS := --release \
                                 shared \
                                 no-deprecated \
                                 enable-devcryptoeng \
                                 no-afalgeng \
                                 no-md2 \
                                 no-md4 \
                                 no-rc2 \
                                 no-rc4 \
                                 no-rc5 \
                                 no-des \
                                 no-idea \
                                 no-camellia \
                                 no-aria \
                                 no-cast \
                                 no-bf \
                                 no-capieng \
                                 no-dh \
                                 no-dsa \
                                 no-dso \
                                 no-dynamic-engine \
                                 no-ec2m \
                                 no-ec_nistp_64_gcc_128 \
                                 no-egd \
                                 no-mdc2 \
                                 no-rmd160 \
                                 no-psk \
                                 no-sm2 \
                                 no-sm3 \
                                 no-sm4\
                                 no-whirlpool \
                                 no-srp \
                                 no-ssl \
                                 no-tls1 \
                                 no-tls1_1 \
                                 no-dtls1 \
                                 no-ssl3-method \
                                 no-tls1-method \
                                 no-tls1_1-method \
                                 no-dtls1-method \
                                 no-filenames \
                                 no-gost \
                                 no-hw-padlock \
                                 no-rdrand \
                                 no-sse2 \
                                 threads \
                                 zlib \
                                 linux-armv4 \
                                 $(OPENSSL_TARGET_CFLAGS) \
                                 $(OPENSSL_TARGET_LDFLAGS)

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

READLINE_SRCDIR                := $(TOPDIR)/src/readline
READLINE_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
READLINE_TARGET_PREFIX         :=
READLINE_TARGET_CONFIGURE_ARGS := $(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
                                  $(call ifdef, \
                                         READLINE_TARGET_CFLAGS, \
                                         CFLAGS="$(READLINE_TARGET_CFLAGS)") \
                                  $(call ifdef, \
                                         READLINE_TARGET_LDFLAGS, \
                                         LDFLAGS="$(READLINE_TARGET_LDFLAGS)") \
                                  --prefix="$(READLINE_TARGET_PREFIX)" \
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
# root SquashFS module
################################################################################

ROOT_SQUASHFS_DEPENDS := tidor_rootfs
ROOT_SQUASHFS_OPTS    := -no-exports -noI -noD -noF -noX

################################################################################
# strace module
################################################################################

STRACE_SRCDIR                := $(TOPDIR)/src/strace
STRACE_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
STRACE_TARGET_PREFIX         :=
STRACE_TARGET_CPPFLAGS       := -isystem $(stagingdir)/usr/include
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
                                --prefix="$(STRACE_TARGET_PREFIX)" \
                                --enable-stacktrace=yes \
                                --enable-mpers=no \
                                --with-libdw
STRACE_TARGET_MAKE_ARGS      := $(XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS) \
                                DESTDIR:=$(stagingdir)

################################################################################
# TiDor burner module
################################################################################

TIDOR_BURNER_SRCDIR := $(TOPDIR)/src/tidor_burner

################################################################################
# TiDor rootfs module
################################################################################

TIDOR_ROOTFS_SRCDIR := $(TOPDIR)/src/tidor_rootfs

################################################################################
# tinit module
################################################################################

TINIT_SRCDIR        := $(TOPDIR)/src/tinit
TINIT_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-

################################################################################
# util_linux module
################################################################################

UTIL_LINUX_SRCDIR                := $(TOPDIR)/src/util_linux
UTIL_LINUX_AUTOTOOLS_ENV         := $(XTCHAIN_AUTOTOOLS_ENV)
UTIL_LINUX_TARGET_PREFIX         :=
UTIL_LINUX_TARGET_CONFIGURE_ARGS := \
	$(XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS) \
	$(call ifdef, \
	       UTIL_LINUX_TARGET_CFLAGS, \
	       CFLAGS="$(UTIL_LINUX_TARGET_CFLAGS)") \
	$(call ifdef, \
	       UTIL_LINUX_TARGET_LDFLAGS, \
	       LDFLAGS="$(UTIL_LINUX_TARGET_LDFLAGS)") \
	NCURSESW6_CONFIG="$(stagingdir)/bin/ncursesw6-config" \
	--prefix="$(UTIL_LINUX_TARGET_PREFIX)" \
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
# utils module
################################################################################

UTILS_SRCDIR        := $(TOPDIR)/src/utils
UTILS_EBUILDDIR     := $(TOPDIR)/src/ebuild
UTILS_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
UTILS_PKGCONF       := $(XTCHAIN_PKGCONF_ENV)

################################################################################
# zlib module
################################################################################

ZLIB_SRCDIR        := $(TOPDIR)/src/zlib
ZLIB_CROSS_COMPILE := $(XTCHAIN_CROSS_COMPILE)-
