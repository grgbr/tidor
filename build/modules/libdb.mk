include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,libpthread)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBDB_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBDB_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBDB_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBDB_TARGET_MAKE_ARGS)

# libdb make invocation macro.
libdb_make = $(call autotools_target_make,$(1),$(LIBDB_TARGET_MAKE_ARGS))

# Location of staged libdb components.
libdb_staging_lib    := \
	$(stagingdir)$(LIBDB_TARGET_PREFIX)/lib/libdb-[0-9].[0-9].so

libdb_staging_bindir := $(stagingdir)$(LIBDB_TARGET_PREFIX)/bin

# TODO:
# * select BDB utilities to install for production/devel builds.
libdb_bins           := db_archive \
                        db_checkpoint \
                        db_deadlock \
                        db_dump \
                        db_hotbackup \
                        db_load \
                        db_log_verify \
                        db_printlog \
                        db_recover \
                        db_stat \
                        db_tuner \
                        db_upgrade \
                        db_verify

# Location of bundled libdb components.
libdb_bundle_libdir := $(bundle_rootdir)$(LIBDB_TARGET_PREFIX)/lib

libdb_bundle_bindir := $(bundle_rootdir)$(LIBDB_TARGET_PREFIX)/bin

################################################################################
# This module help message
################################################################################

define libdb_align_help
$(subst $(space),$(newline)                                  ,$(strip $(1)))
endef

define module_help
Build and install libdb, the Berkeley database library and utilities.
developers.

::Configuration variable::
  LIBDB_SRCDIR                -- Path to source directory tree
                                 [$(LIBDB_SRCDIR)]
  LIBDB_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                 configure invocation time
                                 [$(call libdb_align_help, \
                                         $(LIBDB_AUTOTOOLS_ENV))]
  LIBDB_TARGET_PREFIX         -- Path to architecture-independent files install
                                 root directory
                                 [$(LIBDB_TARGET_PREFIX)]
  LIBDB_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                 configure time
                                 [$(call libdb_align_help, \
                                         $(LIBDB_TARGET_CONFIGURE_ARGS))]
  LIBDB_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                 time
                                 [$(call libdb_align_help, \
                                         $(LIBDB_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)/usr/include/db.h -- Development header
  $$(stagingdir)$(LIBDB_TARGET_PREFIX)/lib/libdb*       -- Static and shared libraries
  $$(stagingdir)$(LIBDB_TARGET_PREFIX)/bin/db_*         -- Utilities

::Bundled::
  $$(bundle_rootdir)$(LIBDB_TARGET_PREFIX)/lib/libdb*.so -- Shared library
  $$(bundle_rootdir)$(LIBDB_TARGET_PREFIX)/bin/db_*      -- Utilities
endef

################################################################################
# Configuration logic
################################################################################

define libdb_configure
$(Q)$(call autotools_target_configure, \
           $(LIBDB_SRCDIR)/dist, \
           $(LIBDB_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libdb_configure)

################################################################################
# Build logic
################################################################################

define libdb_build
+$(Q)$(call libdb_make,all)
endef

$(call autotools_gen_build_rule,libdb_build)

################################################################################
# Clean logic
################################################################################

define libdb_clean
+$(Q)$(call libdb_make,clean)
endef

$(call autotools_gen_clean_rule,libdb_clean)

################################################################################
# Install logic
################################################################################

define libdb_install
+$(Q)$(call libdb_make, \
            install_setup install_include install_lib install_utilities)
endef

$(call autotools_gen_install_rule,libdb_install)

################################################################################
# Uninstall logic
################################################################################

define libdb_uninstall
+$(Q)$(call libdb_make, \
            uninstall_include uninstall_lib uninstall_utilities)
endef

$(call autotools_gen_uninstall_rule,libdb_uninstall)

################################################################################
# Bundle logic
################################################################################

define libdb_bundle
$(Q)$(call bundle_lib_cmd, \
           $(wildcard $(libdb_staging_lib)), \
           $(libdb_bundle_libdir))
$(foreach b, \
          $(libdb_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(libdb_staging_bindir)/$(b), \
                     $(libdb_bundle_bindir))$(newline))
endef

$(call autotools_gen_bundle_rule,libdb_bundle)

################################################################################
# Drop logic
################################################################################

define libdb_drop
$(Q)$(call drop_lib_cmd, \
           $(wildcard $(libdb_staging_lib)), \
           $(libdb_bundle_libdir))
$(foreach b, \
          $(libdb_bins), \
          $(Q)$(call drop_cmd, \
                     $(libdb_bundle_bindir)/$(b))$(newline))
endef

$(call autotools_gen_drop_rule,libdb_drop)
