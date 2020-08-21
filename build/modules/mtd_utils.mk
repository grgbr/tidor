include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,util_linux zlib)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,MTD_UTILS_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,MTD_UTILS_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,MTD_UTILS_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,MTD_UTILS_TARGET_MAKE_ARGS)

# mtd_utils make invocation macro.
mtd_utils_make = $(call autotools_target_make,$(1),$(MTD_UTILS_TARGET_MAKE_ARGS))

# Location of staged mtd_utils
mtd_utils_staging_bindir := $(stagingdir)$(MTD_UTILS_TARGET_PREFIX)/sbin

# Location of bundled mtd_utils
mtd_utils_bundle_bindir := $(bundle_rootdir)$(MTD_UTILS_TARGET_PREFIX)/sbin

# TODO:
# * select utilities to install for production/devel builds.
mtd_utils_bins          := flashcp \
                           flash_erase \
                           flash_lock \
                           flash_unlock \
                           lsmtd \
                           mtd_debug \
                           mtdinfo \
                           mtdpart

################################################################################
# This module help message
################################################################################

define mtd_utils_align_help
$(subst $(space),$(newline)                                      ,$(strip $(1)))
endef

define module_help
Build and install mtd_utils, the Memory Technology Device Utilities.

::Configuration variable::
  MTD_UTILS_SRCDIR                -- Path to source directory tree
                                     [$(MTD_UTILS_SRCDIR)]
  MTD_UTILS_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                     configure invocation time
                                     [$(call mtd_utils_align_help, \
                                             $(MTD_UTILS_AUTOTOOLS_ENV))]
  MTD_UTILS_TARGET_PREFIX         -- Path to architecture-independent files install
                                     root directory
                                     [$(MTD_UTILS_TARGET_PREFIX)]
  MTD_UTILS_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                     configure time
                                     [$(call mtd_utils_align_help, \
                                             $(MTD_UTILS_TARGET_CONFIGURE_ARGS))]
  MTD_UTILS_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                     time
                                     [$(call mtd_utils_align_help, \
                                             $(MTD_UTILS_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(MTD_UTILS_TARGET_PREFIX)/sbin/flash_* -- Binary
  $$(stagingdir)$(MTD_UTILS_TARGET_PREFIX)/sbin/lsmtd
  $$(stagingdir)$(MTD_UTILS_TARGET_PREFIX)/sbin/mtd*

::Bundled::
  $$(bundle_rootdir)$(MTD_UTILS_TARGET_PREFIX)/sbin/flash_* -- Binary
  $$(bundle_rootdir)$(MTD_UTILS_TARGET_PREFIX)/sbin/lsmtd
  $$(bundle_rootdir)$(MTD_UTILS_TARGET_PREFIX)/sbin/mtd*
endef

################################################################################
# Configuration logic
################################################################################

define mtd_utils_configure
$(Q)$(call autotools_target_configure, \
           $(MTD_UTILS_SRCDIR), \
           $(MTD_UTILS_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,mtd_utils_configure)

################################################################################
# Build logic
################################################################################

define mtd_utils_build
+$(Q)$(call mtd_utils_make)
endef

$(call autotools_gen_build_rule,mtd_utils_build)

################################################################################
# Clean logic
################################################################################

define mtd_utils_clean
+$(Q)$(call mtd_utils_make,clean)
endef

$(call autotools_gen_clean_rule,mtd_utils_clean)

################################################################################
# Install logic
################################################################################

define mtd_utils_install
+$(Q)$(call mtd_utils_make,install)
endef

$(call autotools_gen_install_rule,mtd_utils_install)

################################################################################
# Uninstall logic
################################################################################

define mtd_utils_uninstall
+$(Q)$(call mtd_utils_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,mtd_utils_uninstall)

################################################################################
# Bundle logic
################################################################################

define mtd_utils_bundle
$(foreach b, \
          $(mtd_utils_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(mtd_utils_staging_bindir)/$(b), \
                     $(mtd_utils_bundle_bindir))$(newline))
endef

$(call autotools_gen_bundle_rule,mtd_utils_bundle)

################################################################################
# Drop logic
################################################################################

define mtd_utils_drop
$(foreach b, \
          $(mtd_utils_bins), \
          $(Q)$(call drop_cmd, \
                     $(mtd_utils_bundle_bindir)/$(b))$(newline))
endef

$(call autotools_gen_drop_rule,mtd_utils_drop)
