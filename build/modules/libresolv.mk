include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,libc)

libresolv_staging_lib   := $(LIBC_SYSROOT_DIR)/lib/libresolv-[0-9].[0-9]*.so
libresolv_bundle_libdir := $(bundle_rootdir)/lib

$(call dieon_empty,libresolv_staging_lib)

################################################################################
# This module help message
################################################################################

define module_help
Bundle libresolv, the glibc mathematical library.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libresolv.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libresolv_staging_lib)), \
	           $(libresolv_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libresolv_staging_lib)), \
	           $(libresolv_bundle_libdir))
