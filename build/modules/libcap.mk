include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBCAP_SRCDIR)
# Interrupt processing if platform specified no cross toolchain.
$(call dieon_undef_or_empty,LIBCAP_CROSS_COMPILE)

# Basic libcap make invocation macro.
libcap_make := $(MAKE) $(LIBCAP_TARGET_MAKE_ARGS) \
                       $(if $(LIBCAP_CROSS_COMPILE), \
                            CROSS_COMPILE:="$(LIBCAP_CROSS_COMPILE)" \
                            BUILD_CC:="gcc" \
                            CC:="$(LIBCAP_CROSS_COMPILE)gcc" \
                            AR:="$(LIBCAP_CROSS_COMPILE)ar" \
                            AR:="$(LIBCAP_CROSS_COMPILE)ar" \
                            RANLIB:="$(LIBCAP_CROSS_COMPILE)ranlib" \
                            lib:="lib") \
                       $(call ifdef, \
                              LIBCAP_TARGET_CFLAGS, \
                              CFLAGS:="$(LIBCAP_TARGET_CFLAGS)") \
                       $(call ifdef, \
                              LIBCAP_TARGET_LDFLAGS, \
                              LDFLAGS:="$(LIBCAP_TARGET_LDFLAGS)") \
                       DESTDIR:=$(stagingdir)

libcap_staging_sbindir := $(stagingdir)/sbin
libcap_bundle_sbindir  := $(bundle_rootdir)/sbin
libcap_staging_libdir  := $(stagingdir)/lib
libcap_bundle_libdir   := $(bundle_rootdir)/lib

libcap_sbins           := getpcaps capsh getcap setcap
libcap_libs            := libcap.so

################################################################################
# This module help message
################################################################################

define libcap_align_help
$(subst $(space),$(newline)                            ,$(1))
endef

define module_help
Build and install libcap, a library for getting and setting POSIX.1e (formerly
POSIX 6) draft 15 capabilities.

::Configuration variable::
  LIBCAP_SRCDIR         -- Path to source directory tree
                           [$(LIBCAP_SRCDIR)]
  LIBCAP_CROSS_COMPILE  -- Path to cross compiling tool chain
                           [$(LIBCAP_CROSS_COMPILE)]
  LIBCAP_TARGET_CFLAGS  -- Optional extra CFLAGS passed to libcap compile process
                           [$(call libcap_align_help,$(LIBCAP_TARGET_CFLAGS))]
  LIBCAP_TARGET_LDFLAGS -- Optional extra LDFLAGS passed to libcap link process in
                           addition to LIBCAP_CFLAGS
                           [$(call libcap_align_help,$(LIBCAP_TARGET_LDFLAGS))]

::Installed::
  $$(stagingdir)/lib/libcap.so*                -- Shared library
  $$(stagingdir)/lib/libcap.a                  -- Static libraries
  $$(stagingdir)/lib/libpsx.a
  $$(stagingdir)/lib/pkgconfig/libcap.pc       -- pkg-config metadata file
  $$(stagingdir)/lib/pkgconfig/libpsx.pc
  $$(stagingdir)/usr/include/sys/capability.h  -- Development headers
  $$(stagingdir)/usr/include/sys/psx_syscall.h
  $$(stagingdir)/sbin/getpcaps                 -- Utilities
  $$(stagingdir)/sbin/capsh
  $$(stagingdir)/sbin/getcap
  $$(stagingdir)/sbin/setcap

::Bundled::
  $$(bundle_rootdir)/lib/libcap.so* -- Shared library
  $$(bundle_rootdir)/sbin/getpcaps  -- Utilities
  $$(bundle_rootdir)/sbin/capsh
  $$(bundle_rootdir)/sbin/getcap
  $$(bundle_rootdir)/sbin/setcap
endef

################################################################################
# Config logic
################################################################################

$(config_target):
	$(Q)$(call mirror_cmd,--delete $(LIBCAP_SRCDIR)/,$(module_builddir))
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	$(Q)$(libcap_make) -C $(module_builddir)/libcap
	$(Q)$(libcap_make) -C $(module_builddir)/progs
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	$(Q)$(libcap_make) -C $(module_builddir) clean

################################################################################
# Install logic
################################################################################

$(install_target):
	$(Q)$(libcap_make) -C $(module_builddir)/libcap install
	$(Q)$(libcap_make) -C $(module_builddir)/progs install
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(foreach b, \
	          $(libcap_sbins), \
	          $(Q)$(call rmf_cmd,$(stagingdir)/$(b))$(newline))
	$(Q)$(call rmf_cmd,$(stagingdir)/lib/libcap.so*)
	$(Q)$(call rmf_cmd,$(stagingdir)/lib/libcap.a)
	$(Q)$(call rmf_cmd,$(stagingdir)/lib/libpsx.a)
	$(Q)$(call rmf_cmd,$(stagingdir)/lib/pkgconfig/libcap.pc)
	$(Q)$(call rmf_cmd,$(stagingdir)/lib/pkgconfig/libpsx.pc)
	$(Q)$(call rmf_cmd,$(stagingdir)/usr/include/sys/capability.h)
	$(Q)$(call rmf_cmd,$(stagingdir)/usr/include/sys/psx_syscall.h)

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(foreach b, \
	          $(libcap_sbins), \
	          $(Q)$(call bundle_bin_cmd, \
	                     $(libcap_staging_sbindir)/$(b), \
	                     $(libcap_bundle_sbindir))$(newline))
	$(foreach l, \
	          $(libcap_libs), \
	          $(Q)$(call bundle_lib_cmd, \
	                     $(libcap_staging_libdir)/$(l), \
	                     $(libcap_bundle_libdir))$(newline))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(foreach b, \
	          $(libcap_sbins), \
	          $(Q)$(call drop_cmd, \
	                     $(libcap_bundle_sbindir)/$(b))$(newline))
	$(foreach l, \
	          $(libcap_libs), \
	          $(Q)$(call drop_lib_cmd, \
	                     $(libcap_staging_libdir)/$(l), \
	                     $(libcap_bundle_libdir))$(newline))
