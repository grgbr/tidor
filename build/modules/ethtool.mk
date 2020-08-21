include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,libm linux)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,ETHTOOL_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,ETHTOOL_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,ETHTOOL_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,ETHTOOL_TARGET_MAKE_ARGS)

# ethtool make invocation macro.
ethtool_make = $(call autotools_target_make,$(1),$(ETHTOOL_TARGET_MAKE_ARGS))

# Location of staged ethtool
ethtool_staging_bindir := $(stagingdir)$(ETHTOOL_TARGET_PREFIX)/sbin

# Location of bundled ethtool
ethtool_bundle_bindir := $(bundle_rootdir)$(ETHTOOL_TARGET_PREFIX)/sbin

################################################################################
# This module help message
################################################################################

define ethtool_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install ethtool, a tool used to query and control network device
driver and hardware settings, particularly for wired Ethernet devices.

::Configuration variable::
  ETHTOOL_SRCDIR                -- Path to source directory tree
                                   [$(ETHTOOL_SRCDIR)]
  ETHTOOL_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                   configure invocation time
                                   [$(call ethtool_align_help, \
                                           $(ETHTOOL_AUTOTOOLS_ENV))]
  ETHTOOL_TARGET_PREFIX         -- Path to architecture-independent files install
                                   root directory
                                   [$(ETHTOOL_TARGET_PREFIX)]
  ETHTOOL_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call ethtool_align_help, \
                                           $(ETHTOOL_TARGET_CONFIGURE_ARGS))]
  ETHTOOL_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                   time
                                   [$(call ethtool_align_help, \
                                           $(ETHTOOL_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(ETHTOOL_TARGET_PREFIX)/sbin/ethtool                 -- Binary
  $$(stagingdir)/usr/share/man/man8/ethtool.8 -- Man page

::Bundled::
  $$(bundle_rootdir)$(ETHTOOL_TARGET_PREFIX)/sbin/ethtool -- Binary
endef

################################################################################
# Configuration logic
################################################################################

define ethtool_configure
$(Q)$(call autotools_target_configure, \
           $(ETHTOOL_SRCDIR), \
           $(ETHTOOL_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,ethtool_configure)

################################################################################
# Build logic
################################################################################

define ethtool_build
+$(Q)$(call ethtool_make,all)
endef

$(call autotools_gen_build_rule,ethtool_build)

################################################################################
# Clean logic
################################################################################

define ethtool_clean
+$(Q)$(call ethtool_make,clean)
endef

$(call autotools_gen_clean_rule,ethtool_clean)

################################################################################
# Install logic
################################################################################

define ethtool_install
+$(Q)$(call ethtool_make,install)
endef

$(call autotools_gen_install_rule,ethtool_install)

################################################################################
# Uninstall logic
################################################################################

define ethtool_uninstall
+$(Q)$(call ethtool_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,ethtool_uninstall)

################################################################################
# Bundle logic
################################################################################

define ethtool_bundle
$(Q)$(call bundle_bin_cmd, \
           $(ethtool_staging_bindir)/ethtool, \
           $(ethtool_bundle_bindir))
endef

$(call autotools_gen_bundle_rule,ethtool_bundle)

################################################################################
# Drop logic
################################################################################

define ethtool_drop
$(Q)$(call drop_cmd,$(ethtool_bundle_bindir)/ethtool)
endef

$(call autotools_gen_drop_rule,ethtool_drop)
