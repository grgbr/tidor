include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,linux)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBPCAP_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBPCAP_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBPCAP_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBPCAP_TARGET_MAKE_ARGS)

# libpcap make invocation macro.
libpcap_make = $(call autotools_target_make, \
                      $(1), \
                      $(LIBPCAP_TARGET_MAKE_ARGS))

# Location of staged libpcap
libpcap_staging_libdir := $(stagingdir)$(LIBPCAP_TARGET_PREFIX)/lib

# Location of bundled libpcap
libpcap_bundle_libdir  := $(bundle_rootdir)$(LIBPCAP_TARGET_PREFIX)/lib

# Installed / bundled util_linux components
libpcap_libs           := libpcap.so

################################################################################
# This module help message
################################################################################

define libpcap_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install libpcap, a tool used to query and control network device
driver and hardware settings, particularly for wired Ethernet devices.

::Configuration variable::
  LIBPCAP_SRCDIR                -- Path to source directory tree
                                   [$(LIBPCAP_SRCDIR)]
  LIBPCAP_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                   configure invocation time
                                   [$(call libpcap_align_help, \
                                           $(LIBPCAP_AUTOTOOLS_ENV))]
  LIBPCAP_TARGET_PREFIX         -- Path to architecture-independent files install
                                   root directory
                                   [$(LIBPCAP_TARGET_PREFIX)]
  LIBPCAP_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call libpcap_align_help, \
                                           $(LIBPCAP_TARGET_CONFIGURE_ARGS))]
  LIBPCAP_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                   time
                                   [$(call libpcap_align_help, \
                                           $(LIBPCAP_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(LIBPCAP_TARGET_PREFIX)/bin/pcap-config               -- Build configuration tool
  $$(stagingdir)$(LIBPCAP_TARGET_PREFIX)/lib/libpcap.a                 -- State library
  $$(stagingdir)$(LIBPCAP_TARGET_PREFIX)/lib/libpcap.so                -- Shared library
  $$(stagingdir)$(LIBPCAP_TARGET_PREFIX)/lib/pkg-config/libpcap.pc     -- pkg-config metadata file
  $$(stagingdir)/usr/include/pcap/*            -- developement headers
  $$(stagingdir)/usr/share/man/man1/*pcap*.1 -- Man pages
  $$(stagingdir)/usr/share/man/man3/*pcap*.3
  $$(stagingdir)/usr/share/man/man5/*pcap*.5
  $$(stagingdir)/usr/share/man/man7/*pcap*.7

::Bundled::
  $$(bundle_rootdir)$(LIBPCAP_TARGET_PREFIX)/lib/libpcap.so -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define libpcap_configure
$(Q)$(call autotools_target_configure, \
           $(LIBPCAP_SRCDIR), \
           $(LIBPCAP_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libpcap_configure)

################################################################################
# Build logic
################################################################################

define libpcap_build
+$(Q)$(call libpcap_make,all)
endef

$(call autotools_gen_build_rule,libpcap_build)

################################################################################
# Clean logic
################################################################################

define libpcap_clean
+$(Q)$(call libpcap_make,clean)
endef

$(call autotools_gen_clean_rule,libpcap_clean)

################################################################################
# Install logic
################################################################################

define libpcap_install
+$(Q)$(call libpcap_make,install)
endef

$(call autotools_gen_install_rule,libpcap_install)

################################################################################
# Uninstall logic
################################################################################

define libpcap_uninstall
+$(Q)$(call libpcap_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,libpcap_uninstall)

################################################################################
# Bundle logic
################################################################################

define libpcap_bundle
$(foreach l, \
          $(libpcap_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(libpcap_staging_libdir)/$(l), \
                     $(libpcap_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,libpcap_bundle)

################################################################################
# Drop logic
################################################################################

define libpcap_drop
$(foreach l, \
          $(libpcap_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(libpcap_staging_libdir)/$(l), \
                     $(libpcap_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,libpcap_drop)
