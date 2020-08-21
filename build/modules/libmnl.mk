include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBMNL_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBMNL_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBMNL_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBMNL_TARGET_MAKE_ARGS)

# libmnl make invocation macro.
libmnl_make = $(call autotools_target_make,$(1),$(LIBMNL_TARGET_MAKE_ARGS))

# Location of staged libmnl shared library.
libmnl_staging_lib := \
	$(stagingdir)$(LIBMNL_TARGET_PREFIX)/lib/libmnl.so.[0-9].[0-9].[0-9]

# Location of bundled libmnl shared library.
libmnl_bundle_libdir := $(bundle_rootdir)$(LIBMNL_TARGET_PREFIX)/lib

################################################################################
# This module help message
################################################################################

define libmnl_align_help
$(subst $(space),$(newline)                                   ,$(strip $(1)))
endef

define module_help
Build and install libmnl, a minimalistic user-space library oriented to Netlink
developers.

::Configuration variable::
  LIBMNL_SRCDIR                -- Path to source directory tree
                                  [$(LIBMNL_SRCDIR)]
  LIBMNL_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                  configure invocation time
                                  [$(call libmnl_align_help, \
                                          $(LIBMNL_AUTOTOOLS_ENV))]
  LIBMNL_TARGET_PREFIX         -- Path to architecture-independent files install
                                  root directory
                                  [$(LIBMNL_TARGET_PREFIX)]
  LIBMNL_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                  configure time
                                  [$(call libmnl_align_help, \
                                          $(LIBMNL_TARGET_CONFIGURE_ARGS))]
  LIBMNL_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                  time
                                  [$(call libmnl_align_help, \
                                          $(LIBMNL_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)/usr/include/libmnl/*    -- Development headers
  $$(stagingdir)$(LIBMNL_TARGET_PREFIX)/lib/libmnl.*            -- Static and shared libraries
  $$(stagingdir)$(LIBMNL_TARGET_PREFIX)/lib/pkgconfig/libmnl.pc -- pkg-config metadata file

::Bundled::
  $$(bundle_rootdir)$(LIBMNL_TARGET_PREFIX)/lib/libmnl.so.* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define libmnl_configure
$(Q)$(call autotools_target_configure, \
           $(LIBMNL_SRCDIR), \
           $(LIBMNL_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libmnl_configure)

################################################################################
# Build logic
################################################################################

define libmnl_build
+$(Q)$(call libmnl_make,all)
endef

$(call autotools_gen_build_rule,libmnl_build)

################################################################################
# Clean logic
################################################################################

define libmnl_clean
+$(Q)$(call libmnl_make,clean)
endef

$(call autotools_gen_clean_rule,libmnl_clean)

################################################################################
# Install logic
################################################################################

define libmnl_install
+$(Q)$(call libmnl_make,install)
endef

$(call autotools_gen_install_rule,libmnl_install)

################################################################################
# Uninstall logic
################################################################################

define libmnl_uninstall
+$(Q)$(call libmnl_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,libmnl_uninstall)

################################################################################
# Bundle logic
################################################################################

define libmnl_bundle
$(Q)$(call bundle_lib_cmd, \
           $(wildcard $(libmnl_staging_lib)), \
           $(libmnl_bundle_libdir))
endef

$(call autotools_gen_bundle_rule,libmnl_bundle)

################################################################################
# Drop logic
################################################################################

define libmnl_drop
$(Q)$(call drop_lib_cmd, \
           $(wildcard $(libmnl_staging_lib)), \
           $(libmnl_bundle_libdir))
endef

$(call autotools_gen_drop_rule,libmnl_drop)
