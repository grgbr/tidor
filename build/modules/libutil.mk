include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,libc)

libutil_staging_lib   := $(LIBC_SYSROOT_DIR)/lib/libutil-[0-9].[0-9]*.so
libutil_bundle_libdir := $(bundle_rootdir)/lib

$(call dieon_empty,libutil_staging_lib)

################################################################################
# This module help message
################################################################################

define module_help
Bundle libutil, the glibc utility library containing code for «standard»
functions used in many different Unix utilities.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libutil.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libutil_staging_lib)), \
	           $(libutil_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libutil_staging_lib)), \
	           $(libutil_bundle_libdir))
