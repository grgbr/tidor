include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,IPERF_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,IPERF_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,IPERF_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,IPERF_TARGET_MAKE_ARGS)

# iperf make invocation macro.
iperf_make = $(call autotools_target_make, \
                      $(1), \
                      $(IPERF_TARGET_MAKE_ARGS))

# Location of staged iperf
iperf_staging_bindir := $(stagingdir)$(IPERF_TARGET_PREFIX)/bin
iperf_staging_libdir := $(stagingdir)$(IPERF_TARGET_PREFIX)/lib

# Location of bundled iperf
iperf_bundle_bindir  := $(bundle_rootdir)$(IPERF_TARGET_PREFIX)/bin
iperf_bundle_libdir  := $(bundle_rootdir)$(IPERF_TARGET_PREFIX)/lib

# Installed / bundled util_linux components
iperf_bins           := iperf3
iperf_libs           := libiperf.so

################################################################################
# This module help message
################################################################################

define iperf_align_help
$(subst $(space),$(newline)                                  ,$(strip $(1)))
endef

define module_help
Build and install iperf3 iPerf3 is a tool for active measurements of the maximum
achievable bandwidth on IP networks. It supports tuning of various parameters
related to timing, buffers and protocols (TCP, UDP, SCTP with IPv4 and IPv6).

::Configuration variable::
  IPERF_SRCDIR                -- Path to source directory tree
                                 [$(IPERF_SRCDIR)]
  IPERF_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                 configure invocation time
                                 [$(call iperf_align_help, \
                                         $(IPERF_AUTOTOOLS_ENV))]
  IPERF_TARGET_PREFIX         -- Path to architecture-independent files install
                                 root directory
                                 [$(IPERF_TARGET_PREFIX)]
  IPERF_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                 configure time
                                 [$(call iperf_align_help, \
                                         $(IPERF_TARGET_CONFIGURE_ARGS))]
  IPERF_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                 time
                                 [$(call iperf_align_help, \
                                         $(IPERF_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(IPERF_TARGET_PREFIX)/bin/iperf3                    -- Binary
  $$(stagingdir)$(IPERF_TARGET_PREFIX)/lib/libiperf.la               -- Libtool library
  $$(stagingdir)$(IPERF_TARGET_PREFIX)/lib/libiperf.a                -- Static library
  $$(stagingdir)$(IPERF_TARGET_PREFIX)/lib/libiperf.so               -- Shared library
  $$(stagingdir)/usr/include/iperf_api.h       -- libiperf developement header
  $$(stagingdir)/usr/share/man/man1/iperf3.1   -- Man pages
  $$(stagingdir)/usr/share/man/man3/libiperf.3

::Bundled::
  $$(bundle_rootdir)$(IPERF_TARGET_PREFIX)/bin/iperf3      -- Binary
  $$(bundle_rootdir)$(IPERF_TARGET_PREFIX)/lib/libiperf.so -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define iperf_configure
$(Q)$(call autotools_target_configure, \
           $(IPERF_SRCDIR), \
           $(IPERF_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,iperf_configure)

################################################################################
# Build logic
################################################################################

define iperf_build
+$(Q)$(call iperf_make,all)
endef

$(call autotools_gen_build_rule,iperf_build)

################################################################################
# Clean logic
################################################################################

define iperf_clean
+$(Q)$(call iperf_make,clean)
endef

$(call autotools_gen_clean_rule,iperf_clean)

################################################################################
# Install logic
################################################################################

define iperf_install
+$(Q)$(call iperf_make,install)
endef

$(call autotools_gen_install_rule,iperf_install)

################################################################################
# Uninstall logic
################################################################################

define iperf_uninstall
+$(Q)$(call iperf_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,iperf_uninstall)

################################################################################
# Bundle logic
################################################################################

define iperf_bundle
$(foreach b, \
          $(iperf_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(iperf_staging_bindir)/$(b), \
                     $(iperf_bundle_bindir))$(newline))
$(foreach l, \
          $(iperf_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(iperf_staging_libdir)/$(l), \
                     $(iperf_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,iperf_bundle)

################################################################################
# Drop logic
################################################################################

define iperf_drop
$(foreach b, \
          $(iperf_bins), \
          $(Q)$(call drop_cmd, \
                     $(iperf_bundle_bindir)/$(b))$(newline))
$(foreach l, \
          $(iperf_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(iperf_staging_libdir)/$(l), \
                     $(iperf_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,iperf_drop)
