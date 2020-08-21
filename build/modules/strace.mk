include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,elfutils linux librt)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,STRACE_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,STRACE_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,STRACE_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,STRACE_TARGET_MAKE_ARGS)

strace_make = $(call autotools_target_make,$(1),$(STRACE_TARGET_MAKE_ARGS))

# Location of staged strace binary
strace_staging_bindir := $(stagingdir)$(STRACE_TARGET_PREFIX)/bin

# Location of bundled strace binary.
strace_bundle_bindir := $(bundle_rootdir)$(STRACE_TARGET_PREFIX)/bin

################################################################################
# This module help message
################################################################################

define strace_align_help
$(subst $(space),$(newline)                                   ,$(strip $(1)))
endef

define module_help
Build and install strace, a diagnostic, debugging and instructional userspace
utility for Linux. It is used to monitor and tamper with interactions between
processes and the Linux kernel, which include system calls, signal deliveries,
and changes of process state.

::Configuration variable::
  STRACE_SRCDIR                -- Path to source directory tree
                                  [$(STRACE_SRCDIR)]
  STRACE_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                  configure invocation time
                                  [$(call strace_align_help, \
                                          $(STRACE_AUTOTOOLS_ENV))]
  STRACE_TARGET_PREFIX         -- Path to architecture-independent files
                                  install root directory
                                  [$(STRACE_TARGET_PREFIX)]
  STRACE_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                  configure time
                                  [$(call strace_align_help, \
                                          $(STRACE_TARGET_CONFIGURE_ARGS))]
  STRACE_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                  time
                                  [$(call strace_align_help, \
                                          $(STRACE_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(STRACE_TARGET_PREFIX)/bin/strace                  -- strace binary
  $$(stagingdir)/usr/share/man/man1/strace.1 -- strace man page

::Bundled::
  $$(bundle_rootdir)$(STRACE_TARGET_PREFIX)/bin/strace -- strace binary
endef

################################################################################
# Configuration logic
################################################################################

define strace_configure
$(Q)$(call autotools_target_configure, \
           $(STRACE_SRCDIR), \
           $(STRACE_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,strace_configure)

################################################################################
# Build logic
################################################################################

define strace_build
+$(Q)$(call strace_make,all)
endef

$(call autotools_gen_build_rule,strace_build)

################################################################################
# Clean logic
################################################################################

define strace_clean
+$(Q)$(call strace_make,clean)
endef

$(call autotools_gen_clean_rule,strace_clean)

################################################################################
# Install logic
################################################################################

define strace_install
+$(Q)$(call strace_make,install)
endef

$(call autotools_gen_install_rule,strace_install)

################################################################################
# Uninstall logic
################################################################################

define strace_uninstall
+$(Q)$(call strace_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,strace_uninstall)

################################################################################
# Bundle logic
################################################################################

define strace_bundle
$(Q)$(call bundle_bin_cmd, \
           $(strace_staging_bindir)/strace, \
           $(strace_bundle_bindir))
endef

$(call autotools_gen_bundle_rule,strace_bundle)

################################################################################
# Drop logic
################################################################################

define strace_drop
$(Q)$(call drop_cmd,$(strace_bundle_bindir)/strace)
endef

$(call autotools_gen_drop_rule,strace_drop)
