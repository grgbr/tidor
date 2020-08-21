include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,libc)

libcrypt_staging_lib   := $(LIBC_SYSROOT_DIR)/lib/libcrypt-[0-9].[0-9]*.so
libcrypt_bundle_libdir := $(bundle_rootdir)/lib

$(call dieon_empty,libcrypt_staging_lib)

################################################################################
# This module help message
################################################################################

define module_help
Bundle libcrypt, the glibc cryptography library.

::Configuration variable::
  LIBC_SYSROOT_DIR -- Path to C library sysroot directory
                      [$(LIBC_SYSROOT_DIR)]

::Bundled::
  $$(bundle_rootdir)/lib/libcrypt.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libcrypt_staging_lib)), \
	           $(libcrypt_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libcrypt_staging_lib)), \
	           $(libcrypt_bundle_libdir))
