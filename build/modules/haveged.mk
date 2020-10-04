include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,HAVEGED_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,HAVEGED_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,HAVEGED_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,HAVEGED_TARGET_MAKE_ARGS)

haveged_target_enable_olt := $(strip $(if $(HAVEGED_TARGET_ENABLE_OLT), \
                                          $(HAVEGED_TARGET_ENABLE_OLT), \
                                          no))

# haveged make invocation macro.
haveged_make = $(call autotools_target_make, \
                      $(1), \
                      $(HAVEGED_TARGET_MAKE_ARGS))

# Location of staged haveged components
haveged_staging_libdir  := $(stagingdir)$(HAVEGED_TARGET_PREFIX)/lib
haveged_staging_sbindir := $(stagingdir)$(HAVEGED_TARGET_PREFIX)/sbin

# Location of bundled haveged components
haveged_bundle_libdir   := $(bundle_rootdir)$(HAVEGED_TARGET_PREFIX)/lib
haveged_bundle_sbindir  := $(bundle_rootdir)$(HAVEGED_TARGET_PREFIX)/sbin

haveged_sbins := haveged
haveged_libs  := libhavege.so

################################################################################
# This module help message
################################################################################

define haveged_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install haveged, an attempt to provide an easy-to-use, unpredictable
random number generator based upon an adaptation of the HAVEGE algorithm.
Haveged was created to remedy low-entropy conditions in the Linux random device
that can occur under some workloads, especially on headless servers.

::Configuration variable::
  HAVEGED_SRCDIR                -- Path to source directory tree
                                   [$(HAVEGED_SRCDIR)]
  HAVEGED_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                   configure invocation time
                                   [$(call haveged_align_help, \
                                           $(HAVEGED_AUTOTOOLS_ENV))]
  HAVEGED_TARGET_PREFIX         -- Path to architecture-independent files install
                                   root directory
                                   [$(HAVEGED_TARGET_PREFIX)]
  HAVEGED_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call haveged_align_help, \
                                           $(HAVEGED_TARGET_CONFIGURE_ARGS))]
  HAVEGED_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                   time
                                   [$(call haveged_align_help, \
                                           $(HAVEGED_TARGET_MAKE_ARGS))]
  HAVEGED_TARGET_ENABLE_OLT     -- Enable AIS-31 online testing support
                                   [$(call haveged_align_help, \
                                           $(haveged_target_enable_olt))]

::Installed::
  $$(stagingdir)$(HAVEGED_TARGET_PREFIX)/sbin/haveged                   -- Daemon binary
  $$(stagingdir)$(HAVEGED_TARGET_PREFIX)/lib/libhaveged.so*             -- Shared library
  $$(stagingdir)$(HAVEGED_TARGET_PREFIX)/lib/libhaveged.la              -- Libtool library
  $$(stagingdir)/usr/include/haveged/*          -- Development headers
  $$(stagingdir)/usr/share/man/man3/libhavege.3 -- Man pages
  $$(stagingdir)/usr/share/man/man8/haveged.8

::Bundled::
  $$(bundle_rootdir)$(HAVEGED_TARGET_PREFIX)/sbin/haveged       -- Daemon binary
  $$(bundle_rootdir)$(HAVEGED_TARGET_PREFIX)/lib/libhaveged.so* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define haveged_configure
$(Q)$(call autotools_target_configure, \
           $(HAVEGED_SRCDIR), \
           $(HAVEGED_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share \
           --enable-olt=$(haveged_target_enable_olt))
endef

$(call autotools_gen_config_rules,haveged_configure)

################################################################################
# Build logic
################################################################################

define haveged_build
+$(Q)$(call haveged_make,all)
endef

$(call autotools_gen_build_rule,haveged_build)

################################################################################
# Clean logic
################################################################################

define haveged_clean
+$(Q)$(call haveged_make,clean)
endef

$(call autotools_gen_clean_rule,haveged_clean)

################################################################################
# Install logic
################################################################################

define haveged_install
+$(Q)$(call haveged_make,install)
endef

$(call autotools_gen_install_rule,haveged_install)

################################################################################
# Uninstall logic
################################################################################

define haveged_uninstall
+$(Q)$(call haveged_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,haveged_uninstall)

################################################################################
# Bundle logic
################################################################################

define haveged_bundle
$(foreach l, \
          $(haveged_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(haveged_staging_libdir)/$(l), \
                     $(haveged_bundle_libdir))$(newline))
$(foreach b, \
          $(haveged_sbins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(haveged_staging_sbindir)/$(b), \
                     $(haveged_bundle_sbindir))$(newline))
endef

$(call autotools_gen_bundle_rule,haveged_bundle)

################################################################################
# Drop logic
################################################################################

define haveged_drop
$(foreach l, \
          $(haveged_libs), \
          $(Q)$(call drop_cmd, \
                     $(haveged_bundle_sbindir)/$(l))$(newline))
$(foreach b, \
          $(haveged_sbins), \
          $(Q)$(call drop_cmd, \
                     $(haveged_bundle_sbindir)/$(b))$(newline))
endef

$(call autotools_gen_drop_rule,haveged_drop)
