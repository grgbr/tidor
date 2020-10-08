include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,libunistring)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBIDN2_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBIDN2_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBIDN2_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBIDN2_TARGET_MAKE_ARGS)

# libidn2 make invocation macro.
libidn2_make = $(call autotools_target_make, \
                      $(1), \
                      $(LIBIDN2_TARGET_MAKE_ARGS))

# Location of libidn2 components
libidn2_staging_libdir := $(stagingdir)$(LIBIDN2_TARGET_PREFIX)/lib
libidn2_bundle_libdir  := $(bundle_rootdir)$(LIBIDN2_TARGET_PREFIX)/lib

libidn2_libs := libidn2.so

################################################################################
# This module help message
################################################################################

define libidn2_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install libidn2, a package designed for internationalized string
handling based on standards from the Internet Engineering Task Force (IETF)\'s
IDN working group, designed for internationalized domain names.

::Configuration variable::
  LIBIDN2_SRCDIR                -- Path to source directory tree
                                   [$(LIBIDN2_SRCDIR)]
  LIBIDN2_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                   configure invocation time
                                   [$(call libidn2_align_help, \
                                           $(LIBIDN2_AUTOTOOLS_ENV))]
  LIBIDN2_TARGET_PREFIX         -- Path to architecture-independent files install
                                   root directory
                                   [$(LIBIDN2_TARGET_PREFIX)]
  LIBIDN2_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call libidn2_align_help, \
                                           $(LIBIDN2_TARGET_CONFIGURE_ARGS))]
  LIBIDN2_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                   time
                                   [$(call libidn2_align_help, \
                                           $(LIBIDN2_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(LIBIDN2_TARGET_PREFIX)/bin/idn2                    -- Binary tool
  $$(stagingdir)$(LIBIDN2_TARGET_PREFIX)/lib/libidn2.so*             -- Shared library
  $$(stagingdir)$(LIBIDN2_TARGET_PREFIX)/lib/libidn2.a               -- Static library
  $$(stagingdir)$(LIBIDN2_TARGET_PREFIX)/lib/libidn2.la              -- Libtool library
  $$(stagingdir)$(LIBIDN2_TARGET_PREFIX)/lib/pkgconfig/libidn2.pc    -- pkg-config metadata file
  $$(stagingdir)/usr/include/idn2.h          -- Development headers
  $$(stagingdir)/usr/share/info/libidn2.info -- Info file
  $$(stagingdir)/usr/share/man1/idn2.1       -- Man pages
  $$(stagingdir)/usr/share/man3/idn2*.3

::Bundled::
  $$(bundle_rootdir)$(LIBIDN2_TARGET_PREFIX)/lib/libidn2.so* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define libidn2_configure
$(Q)$(call autotools_target_configure, \
           $(LIBIDN2_SRCDIR), \
           $(LIBIDN2_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libidn2_configure)

################################################################################
# Build logic
################################################################################

define libidn2_build
+$(Q)$(call libidn2_make,all)
endef

$(call autotools_gen_build_rule,libidn2_build)

################################################################################
# Clean logic
################################################################################

define libidn2_clean
+$(Q)$(call libidn2_make,clean)
endef

$(call autotools_gen_clean_rule,libidn2_clean)

################################################################################
# Install logic
################################################################################

define libidn2_install
+$(Q)$(call libidn2_make,install)
endef

$(call autotools_gen_install_rule,libidn2_install)

################################################################################
# Uninstall logic
################################################################################

define libidn2_uninstall
+$(Q)$(call libidn2_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,libidn2_uninstall)

################################################################################
# Bundle logic
################################################################################

define libidn2_bundle
$(foreach l, \
          $(libidn2_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(libidn2_staging_libdir)/$(l), \
                     $(libidn2_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,libidn2_bundle)

################################################################################
# Drop logic
################################################################################

define libidn2_drop
$(foreach l, \
          $(libidn2_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(libidn2_staging_libdir)/$(l), \
                     $(libidn2_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,libidn2_drop)
