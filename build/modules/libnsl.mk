include $(CRAFTERDIR)/core/module.mk

$(call dieon_undef_or_empty,LIBC_SYSROOT_DIR)

$(call gen_module_depends,libc)

libnsl_staging_lib       := $(LIBC_SYSROOT_DIR)/lib/libnsl-[0-9].[0-9]*.so
libnsl_bundle_libdir     := $(bundle_rootdir)/lib
libnsl_bundle_sysconfdir := $(bundle_rootdir)/etc

################################################################################
# This module help message
################################################################################

define module_help
Bundle libnsl, the glibc NIS/NIS+ library.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libnsl.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libnsl_staging_lib)), \
	           $(libnsl_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libnsl_staging_lib)), \
	           $(libnsl_bundle_libdir))
