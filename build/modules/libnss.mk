include $(CRAFTERDIR)/core/module.mk

$(call dieon_undef_or_empty,LIBC_SYSROOT_DIR)

libnss_staging_lib       := $(LIBC_SYSROOT_DIR)/lib/libnss_files-[0-9].[0-9]*.so
libnss_bundle_libdir     := $(bundle_rootdir)/lib
libnss_bundle_sysconfdir := $(bundle_rootdir)/etc

$(gen_module_depends,iana_etc)

################################################################################
# This module help message
################################################################################

define module_help
Bundle libnss, the glibc name service switch libraries.

::Configuration variable::
  LIBC_SYSROOT_DIR          -- Path to C library sysroot directory
                               [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libnss_files.so* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libnss_staging_lib)), \
	           $(libnss_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libnss_staging_lib)), \
	           $(libnss_bundle_libdir))
