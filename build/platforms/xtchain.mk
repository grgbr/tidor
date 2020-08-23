XTCHAIN_HOST_DIR ?= /opt/xtchain
XTCHAIN_HOST_DIR := $(realpath $(XTCHAIN_HOST_DIR))
ifeq ($(XTCHAIN_HOST_DIR),)
$(error Invalid path to XTCHAIN toolchain host tools: no such directory !)
endif

XTCHAIN_TARGET_DIR := $(realpath $(XTCHAIN_TARGET_DIR))
ifeq ($(XTCHAIN_TARGET_DIR),)
$(error Invalid path to XTCHAIN toolchain target tools: no such directory !)
endif

xtchain_gcc_path := $(wildcard $(XTCHAIN_TARGET_DIR)/bin/*-gcc)
ifeq ($(xtchain_gcc_path),)
$(error Invalid path to XTCHAIN toolchain target GCC: no such file !)
endif

# Do not use config.guess since it is slow and this variable is expanded quite
# a number of times, making command line completion unresponsive...
XTCHAIN_BUILD_MACHINE := $(shell arch)-unknown-linux-gnu
ifeq ($(XTCHAIN_BUILD_MACHINE),)
$(error Empty XTCHAIN toolchain build GCC machine !)
endif

XTCHAIN_TARGET_MACHINE := $(shell $(xtchain_gcc_path) -dumpmachine)
ifeq ($(XTCHAIN_TARGET_MACHINE),)
$(error Empty XTCHAIN toolchain target GCC machine !)
endif

XTCHAIN_PATH := $(XTCHAIN_TARGET_DIR)/bin:$(XTCHAIN_HOST_DIR)/bin:$(PATH)

XTCHAIN_SYSROOT := $(XTCHAIN_TARGET_DIR)/$(XTCHAIN_TARGET_MACHINE)/sysroot

XTCHAIN_CROSS_COMPILE := $(XTCHAIN_TARGET_DIR)/bin/$(XTCHAIN_TARGET_MACHINE)

XTCHAIN_PKGCONF_ENV := \
	PKG_CONFIG="$(XTCHAIN_HOST_DIR)/bin/pkg-config" \
	PKG_CONFIG_LIBDIR="$(XTCHAIN_SYSROOT)/usr/lib/pkgconfig" \
	PKG_CONFIG_PATH="$(stagingdir)/lib/pkgconfig" \
	PKG_CONFIG_SYSROOT_DIR="$(stagingdir)"

XTCHAIN_AUTORECONF := $(XTCHAIN_HOST_DIR)/bin/autoreconf

XTCHAIN_AUTOTOOLS_ENV := \
	PATH="$(XTCHAIN_PATH)" \
	AUTOCONF="$(XTCHAIN_HOST_DIR)/bin/autoconf" \
	AUTORECONF="$(XTCHAIN_AUTORECONF)" \
	AUTOHEADER="$(XTCHAIN_HOST_DIR)/bin/autoheader" \
	AUTOM4TE="$(XTCHAIN_HOST_DIR)/bin/autom4te" \
	AUTOMAKE="$(XTCHAIN_HOST_DIR)/bin/automake" \
	ACLOCAL="$(XTCHAIN_HOST_DIR)/bin/aclocal" \
	LIBTOOLIZE="$(XTCHAIN_HOST_DIR)/bin/libtoolize" \
	LIBTOOL="$(XTCHAIN_HOST_DIR)/bin/libtool"

XTCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS := \
	--build="$(XTCHAIN_BUILD_MACHINE)" \
	--host="$(XTCHAIN_TARGET_MACHINE)" \
	$(XTCHAIN_AUTOTOOLS_ENV) \
	$(XTCHAIN_PKGCONF_ENV) \
	MANIFEST_TOOL="$(XTCHAIN_TARGET_DIR)/bin/$(XTCHAIN_TARGET_MACHINE)-mt"

XTCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS := \
	PATH:="$(XTCHAIN_PATH)"

XTCHAIN_CMAKE_TARGET_CONFIGURE_ARGS := \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_PROGRAM_PATH="$(XTCHAIN_PATH)" \
	-DCMAKE_C_COMPILER="$(XTCHAIN_CROSS_COMPILE)-gcc" \
	-DCMAKE_CXX_COMPILER="$(XTCHAIN_CROSS_COMPILE)-g++" \
	-DCMAKE_LINKER="$(XTCHAIN_CROSS_COMPILE)-ld" \
	-DCMAKE_AR="$(XTCHAIN_CROSS_COMPILE)-ar" \
	-DCMAKE_NM="$(XTCHAIN_CROSS_COMPILE)-nm" \
	-DCMAKE_OBJCOPY="$(XTCHAIN_CROSS_COMPILE)-objcopy" \
	-DCMAKE_OBJDUMP="$(XTCHAIN_CROSS_COMPILE)-objdump" \
	-DCMAKE_RANLIB="$(XTCHAIN_CROSS_COMPILE)-ranlib" \
	-DCMAKE_STRIP="$(XTCHAIN_CROSS_COMPILE)-strip"
