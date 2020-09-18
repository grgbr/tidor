include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,NETPERF_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,NETPERF_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,NETPERF_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,NETPERF_TARGET_MAKE_ARGS)

# netperf make invocation macro.
netperf_make = $(call autotools_target_make, \
                      $(1), \
                      $(NETPERF_TARGET_MAKE_ARGS))

# Location of staged netperf
netperf_staging_bindir := $(stagingdir)$(NETPERF_TARGET_PREFIX)/bin

# Location of bundled netperf
netperf_bundle_bindir  := $(bundle_rootdir)$(NETPERF_TARGET_PREFIX)/bin

# Installed / bundled util_linux components
netperf_bins           := netperf netserver

################################################################################
# This module help message
################################################################################

define netperf_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install netperf, a benchmark that can be used to measure the
performance of many different types of networking. It provides tests for both
unidirectional throughput, and end-to-end latency.

::Configuration variable::
  NETPERF_SRCDIR                -- Path to source directory tree
                                   [$(NETPERF_SRCDIR)]
  NETPERF_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                   configure invocation time
                                   [$(call netperf_align_help, \
                                           $(NETPERF_AUTOTOOLS_ENV))]
  NETPERF_TARGET_PREFIX         -- Path to architecture-independent files install
                                   root directory
                                   [$(NETPERF_TARGET_PREFIX)]
  NETPERF_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call netperf_align_help, \
                                           $(NETPERF_TARGET_CONFIGURE_ARGS))]
  NETPERF_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                   time
                                   [$(call netperf_align_help, \
                                           $(NETPERF_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(NETPERF_TARGET_PREFIX)/bin/netperf                    -- Binaries
  $$(stagingdir)$(NETPERF_TARGET_PREFIX)/bin/netserver
  $$(stagingdir)/usr/share/man/man1/netperf.1   -- Man pages
  $$(stagingdir)/usr/share/man/man1/netserver.1
  $$(stagingdir)/usr/share/info/netperf.info    -- Info page

::Bundled::
  $$(bundle_rootdir)$(NETPERF_TARGET_PREFIX)/bin/netperf   -- Binaries
  $$(bundle_rootdir)$(NETPERF_TARGET_PREFIX)/bin/netserver
endef

################################################################################
# Configuration logic
################################################################################

define netperf_configure
$(Q)$(call autotools_target_configure, \
           $(NETPERF_SRCDIR), \
           $(NETPERF_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,netperf_configure)

################################################################################
# Build logic
################################################################################

define netperf_build
+$(Q)$(call netperf_make,all)
endef

$(call autotools_gen_build_rule,netperf_build)

################################################################################
# Clean logic
################################################################################

define netperf_clean
+$(Q)$(call netperf_make,clean)
endef

$(call autotools_gen_clean_rule,netperf_clean)

################################################################################
# Install logic
################################################################################

define netperf_install
+$(Q)$(call netperf_make,install)
endef

$(call autotools_gen_install_rule,netperf_install)

################################################################################
# Uninstall logic
################################################################################

define netperf_uninstall
+$(Q)$(call netperf_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,netperf_uninstall)

################################################################################
# Bundle logic
################################################################################

define netperf_bundle
$(foreach b, \
          $(netperf_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(netperf_staging_bindir)/$(b), \
                     $(netperf_bundle_bindir))$(newline))
endef

$(call autotools_gen_bundle_rule,netperf_bundle)

################################################################################
# Drop logic
################################################################################

define netperf_drop
$(foreach b, \
          $(netperf_bins), \
          $(Q)$(call drop_cmd, \
                     $(netperf_bundle_bindir)/$(b))$(newline))
endef

$(call autotools_gen_drop_rule,netperf_drop)
