include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBMAXMINDDB_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBMAXMINDDB_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBMAXMINDDB_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBMAXMINDDB_TARGET_MAKE_ARGS)

# libmaxminddb make invocation macro.
libmaxminddb_make = $(call autotools_target_make, \
                           $(1), \
                           $(LIBMAXMINDDB_TARGET_MAKE_ARGS))

# Location of libmaxminddb components
libmaxminddb_staging_libdir := $(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib
libmaxminddb_bundle_libdir  := $(bundle_rootdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib
libmaxminddb_staging_bindir := $(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/bin
libmaxminddb_bundle_bindir  := $(bundle_rootdir)$(LIBMAXMINDDB_TARGET_PREFIX)/bin

libmaxminddb_libs := libmaxminddb.so
libmaxminddb_bins := mmdblookup

################################################################################
# This module help message
################################################################################

define libmaxminddb_align_help
$(subst $(space),$(newline)                                         ,$(strip $(1)))
endef

define module_help
Build and install libmaxminddb, a library to manipulate MaxMind DB file format
for storing information about IP addresses in a highly optimized, flexible
database format.

::Configuration variable::
  LIBMAXMINDDB_SRCDIR                -- Path to source directory tree
                                        [$(LIBMAXMINDDB_SRCDIR)]
  LIBMAXMINDDB_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                        configure invocation time
                                        [$(call libmaxminddb_align_help, \
                                                $(LIBMAXMINDDB_AUTOTOOLS_ENV))]
  LIBMAXMINDDB_TARGET_PREFIX         -- Path to architecture-independent files install
                                        root directory
                                        [$(LIBMAXMINDDB_TARGET_PREFIX)]
  LIBMAXMINDDB_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                        configure time
                                        [$(call libmaxminddb_align_help, \
                                                $(LIBMAXMINDDB_TARGET_CONFIGURE_ARGS))]
  LIBMAXMINDDB_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                        time
                                        [$(call libmaxminddb_align_help, \
                                                $(LIBMAXMINDDB_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/bin/mmdblookup                    -- Binary
  $$(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib/libmaxminddb.so*              -- Shared library
  $$(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib/libmaxminddb.a                -- Static library
  $$(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib/libmaxminddb.la               -- Libtool library
  $$(stagingdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib/pkgconfig/libmaxminddb.pc     -- pkg-config metadata file
  $$(stagingdir)/usr/include/maxminddb.h           -- Development headers
  $$(stagingdir)/usr/share/man/man1/mmdblookup.1   -- Man pages
  $$(stagingdir)/usr/share/man/man3/libmaxminddb.3

::Bundled::
  $$(bundle_rootdir)$(LIBMAXMINDDB_TARGET_PREFIX)/bin/mmdblookup       -- Binary
  $$(bundle_rootdir)$(LIBMAXMINDDB_TARGET_PREFIX)/lib/libmaxminddb.so* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define libmaxminddb_configure
$(Q)$(call autotools_target_configure, \
           $(LIBMAXMINDDB_SRCDIR), \
           $(LIBMAXMINDDB_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libmaxminddb_configure)

################################################################################
# Build logic
################################################################################

define libmaxminddb_build
+$(Q)$(call libmaxminddb_make,all)
endef

$(call autotools_gen_build_rule,libmaxminddb_build)

################################################################################
# Clean logic
################################################################################

define libmaxminddb_clean
+$(Q)$(call libmaxminddb_make,clean)
endef

$(call autotools_gen_clean_rule,libmaxminddb_clean)

################################################################################
# Install logic
################################################################################

define libmaxminddb_install
+$(Q)$(call libmaxminddb_make,install)
endef

$(call autotools_gen_install_rule,libmaxminddb_install)

################################################################################
# Uninstall logic
################################################################################

define libmaxminddb_uninstall
+$(Q)$(call libmaxminddb_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,libmaxminddb_uninstall)

################################################################################
# Bundle logic
################################################################################

define libmaxminddb_bundle
$(foreach b, \
          $(libmaxminddb_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(libmaxminddb_staging_bindir)/$(b), \
                     $(libmaxminddb_bundle_bindir))$(newline))
$(foreach l, \
          $(libmaxminddb_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(libmaxminddb_staging_libdir)/$(l), \
                     $(libmaxminddb_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,libmaxminddb_bundle)

################################################################################
# Drop logic
################################################################################

define libmaxminddb_drop
$(foreach b, \
          $(libmaxminddb_bins), \
          $(Q)$(call drop_cmd, \
                     $(libmaxminddb_bundle_bindir)/$(b))$(newline))
$(foreach l, \
          $(libmaxminddb_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(libmaxminddb_staging_libdir)/$(l), \
                     $(libmaxminddb_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,libmaxminddb_drop)
