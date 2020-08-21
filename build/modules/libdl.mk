include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,libc)

libdl_staging_lib   := $(LIBC_SYSROOT_DIR)/lib/libdl-[0-9].[0-9]*.so
libdl_bundle_libdir := $(bundle_rootdir)/lib

$(call dieon_empty,libdl_staging_lib)

################################################################################
# This module help message
################################################################################

define module_help
Bundle libdl, the glibc dynamic linking interface library.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libdl.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libdl_staging_lib)), \
	           $(libdl_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libdl_staging_lib)), \
	           $(libdl_bundle_libdir))
