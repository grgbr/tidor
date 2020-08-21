ICCHAIN_HOST_DIR ?= /opt/icchain
ICCHAIN_HOST_DIR := $(realpath $(ICCHAIN_HOST_DIR))
ifeq ($(ICCHAIN_HOST_DIR),)
$(error Invalid path to IC toolchain host tools: no such directory !)
endif

ICCHAIN_TARGET_DIR := $(realpath $(ICCHAIN_TARGET_DIR))
ifeq ($(ICCHAIN_HOST_DIR),)
$(error Invalid path to IC toolchain target tools: no such directory !)
endif

icchain_gcc_path := $(wildcard $(ICCHAIN_TARGET_DIR)/bin/*-gcc)
ifeq ($(icchain_gcc_path),)
$(error Invalid path to IC toolchain target GCC: no such file !)
endif

# Do not use config.guess since it is slow and this variable is expanded quite
# a number of times, making command line completion unresponsive...
ICCHAIN_BUILD_MACHINE := $(shell arch)-unknown-linux-gnu
ifeq ($(ICCHAIN_BUILD_MACHINE),)
$(error Empty IC toolchain build GCC machine !)
endif

ICCHAIN_TARGET_MACHINE := $(shell $(icchain_gcc_path) -dumpmachine)
ifeq ($(ICCHAIN_TARGET_MACHINE),)
$(error Empty IC toolchain target GCC machine !)
endif

ICCHAIN_PATH := $(ICCHAIN_TARGET_DIR)/bin:$(ICCHAIN_HOST_DIR)/bin:$(PATH)

ICCHAIN_SYSROOT := $(ICCHAIN_TARGET_DIR)/$(ICCHAIN_TARGET_MACHINE)/libc

ICCHAIN_CROSS_COMPILE := $(ICCHAIN_TARGET_DIR)/bin/$(ICCHAIN_TARGET_MACHINE)

ICCHAIN_PKGCONF_ENV := \
	PKG_CONFIG="$(ICCHAIN_HOST_DIR)/bin/pkg-config" \
	PKG_CONFIG_LIBDIR="$(ICCHAIN_TARGET_DIR)/usr/lib/pkgconfig" \
	PKG_CONFIG_PATH="$(stagingdir)/lib/pkgconfig" \
	PKG_CONFIG_SYSROOT_DIR="$(stagingdir)"

ICCHAIN_AUTORECONF := $(ICCHAIN_HOST_DIR)/bin/autoreconf

ICCHAIN_AUTOTOOLS_ENV := \
	PATH="$(ICCHAIN_PATH)" \
	AUTOCONF="$(ICCHAIN_HOST_DIR)/bin/autoconf" \
	AUTORECONF="$(ICCHAIN_AUTORECONF)" \
	AUTOHEADER="$(ICCHAIN_HOST_DIR)/bin/autoheader" \
	AUTOM4TE="$(ICCHAIN_HOST_DIR)/bin/autom4te" \
	AUTOMAKE="$(ICCHAIN_HOST_DIR)/bin/automake" \
	ACLOCAL="$(ICCHAIN_HOST_DIR)/bin/aclocal" \
	LIBTOOLIZE="$(ICCHAIN_HOST_DIR)/bin/libtoolize" \
	LIBTOOL="$(ICCHAIN_HOST_DIR)/bin/libtool"

ICCHAIN_AUTOTOOLS_TARGET_CONFIGURE_ARGS := \
	--build="$(ICCHAIN_BUILD_MACHINE)" \
	--host="$(ICCHAIN_TARGET_MACHINE)" \
	$(ICCHAIN_AUTOTOOLS_ENV) \
	$(ICCHAIN_PKGCONF_ENV) \
	MANIFEST_TOOL="$(ICCHAIN_TARGET_DIR)/bin/$(ICCHAIN_TARGET_MACHINE)-mt"

ICCHAIN_AUTOTOOLS_TARGET_MAKE_ARGS := \
	PATH:="$(ICCHAIN_PATH)"

ICCHAIN_CMAKE_TARGET_CONFIGURE_ARGS := \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_PROGRAM_PATH="$(ICCHAIN_PATH)" \
	-DCMAKE_C_COMPILER="$(ICCHAIN_CROSS_COMPILE)-gcc" \
	-DCMAKE_CXX_COMPILER="$(ICCHAIN_CROSS_COMPILE)-g++" \
	-DCMAKE_LINKER="$(ICCHAIN_CROSS_COMPILE)-ld" \
	-DCMAKE_AR="$(ICCHAIN_CROSS_COMPILE)-ar" \
	-DCMAKE_NM="$(ICCHAIN_CROSS_COMPILE)-nm" \
	-DCMAKE_OBJCOPY="$(ICCHAIN_CROSS_COMPILE)-objcopy" \
	-DCMAKE_OBJDUMP="$(ICCHAIN_CROSS_COMPILE)-objdump" \
	-DCMAKE_RANLIB="$(ICCHAIN_CROSS_COMPILE)-ranlib" \
	-DCMAKE_STRIP="$(ICCHAIN_CROSS_COMPILE)-strip"
