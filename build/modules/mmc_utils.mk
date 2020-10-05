include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,MMC_UTILS_SRCDIR)
# Interrupt processing if platform specified no cross toolchain.
$(call dieon_undef_or_empty,MMC_UTILS_CROSS_COMPILE)

# Basic mmc_utils make invocation macro.
mmc_utils_make := $(MAKE) --makefile $(MMC_UTILS_SRCDIR)/Makefile \
                          -C $(module_builddir) \
                          prefix:=/usr \
                          bindir:=/bin \
                          CC:="$(MMC_UTILS_CROSS_COMPILE)gcc" \
                          CFLAGS:="$(MMC_UTILS_CFLAGS)" \
                          LDFLAGS:="$(MMC_UTILS_LDFLAGS)"

# Location of staged mmc_utils shared library.
mmc_utils_staging_bindir := $(stagingdir)/bin

# Location of bundled mmc_utils shared library.
mmc_utils_bundle_bindir := $(bundle_rootdir)/bin

################################################################################
# This module help message
################################################################################

define mmc_utils_align_help
$(subst $(space),$(newline)                              ,$(strip $(1)))
endef

define module_help
Build and install mmc-utils, userspace tools for MMC/SD devices.

::Configuration variable::
  MMC_UTILS_SRCDIR        -- Path to source directory tree
                             [$(MMC_UTILS_SRCDIR)]
  MMC_UTILS_CROSS_COMPILE -- Path to cross compiling tool chain
                             [$(MMC_UTILS_CROSS_COMPILE)]
  MMC_UTILS_CFLAGS        -- Optional extra CFLAGS passed to mmc_utils compile process
                             [$(call mmc_utils_align_help,$(MMC_UTILS_CFLAGS))]
  MMC_UTILS_LDFLAGS       -- Optional extra LDFLAGS passed to mmc_utils link process in
                             addition to MMC_UTILS_CFLAGS
                             [$(call mmc_utils_align_help,$(MMC_UTILS_LDFLAGS))]

::Installed::
  $$(stagingdir)/bin/mmc     -- Utility

::Bundled::
  $$(bundle_rootdir)/bin/mmc -- Utility
endef

################################################################################
# Config logic
################################################################################

$(config_target):
	$(Q)$(call mirror_cmd,--delete $(MMC_UTILS_SRCDIR)/,$(module_builddir))
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(mmc_utils_make)
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(Q)$(mmc_utils_make) clean

################################################################################
# Install logic
################################################################################

$(install_target):
	+$(Q)$(mmc_utils_make) install DESTDIR:=$(stagingdir)
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call rmf_cmd,$(stagingdir)/bin/mmc)

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_bin_cmd, \
	           $(mmc_utils_staging_bindir)/mmc, \
	           $(mmc_utils_bundle_bindir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_cmd,$(mmc_utils_bundle_bindir)/mmc)
