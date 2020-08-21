include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,libc)

libpthread_staging_lib   := $(LIBC_SYSROOT_DIR)/lib/libpthread-[0-9].[0-9]*.so
libpthread_bundle_libdir := $(bundle_rootdir)/lib

$(call dieon_empty,libpthread_staging_lib)

################################################################################
# This module help message
################################################################################

define module_help
Bundle libpthread, the glibc POSIX threads library.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libpthread.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libpthread_staging_lib)), \
	           $(libpthread_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libpthread_staging_lib)), \
	           $(libpthread_bundle_libdir))
