include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,libpthread)

librt_staging_lib   := $(LIBC_SYSROOT_DIR)/lib/librt-[0-9].[0-9]*.so
librt_bundle_libdir := $(bundle_rootdir)/lib

$(call dieon_empty,librt_staging_lib)

################################################################################
# This module help message
################################################################################

define module_help
Bundle librt, the glibc POSIX realtime extension library.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/librt.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(librt_staging_lib)), \
	           $(librt_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(librt_staging_lib)), \
	           $(librt_bundle_libdir))
