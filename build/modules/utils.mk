include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call dieon_undef_or_empty,UTILS_SRCDIR)
$(call dieon_undef_or_empty,UTILS_EBUILDDIR)
$(call dieon_undef_or_empty,UTILS_CROSS_COMPILE)

utils_cflags  := $(UTILS_CFLAGS) -I$(stagingdir)/usr/include
utils_ldflags := $(UTILS_LDFLAGS) -L$(stagingdir)/lib

# Additional utils specific make arguments given to ebuild commands
utils_make_args := \
	EBUILDDIR:="$(UTILS_EBUILDDIR)" \
	CROSS_COMPILE:="$(UTILS_CROSS_COMPILE)" \
	PREFIX:=/ \
	INCLUDEDIR:=/usr/include \
	EXTRA_CFLAGS:="$(utils_cflags)" \
	EXTRA_LDFLAGS:="$(utils_ldflags)" \

define utils_make_cmd
$(call ebuild_make_cmd,$(UTILS_SRCDIR),$(1),$(utils_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define utils_align_help
$(subst $(space),$(newline)                          ,$(strip $(1)))
endef

define module_help
Build utils, a busybox runit / glibc based init.

::Configuration variables::
  UTILS_SRCDIR         -- Path to utils source tree root directory
                          [$(UTILS_SRCDIR)]
  UTILS_EBUILDDIR      -- Path to ebuild source tree root directory
                          [$(UTILS_EBUILDDIR)]
  UTILS_DEFCONFIG_FILE -- Optional default build configuration file path
                          [$(UTILS_DEFCONFIG_FILE)]
  UTILS_CONFIG_FILES   -- Additional configuration files merged with current
                          configuration
                          [$(UTILS_CONFIG_FILES)]
  UTILS_CROSS_COMPILE  -- Path to utils cross compiling tool chain
                          [$(UTILS_CROSS_COMPILE)]
  UTILS_CFLAGS         -- Optional extra CFLAGS passed to utils compile
                          process
                          [$(call utils_align_help,$(UTILS_CFLAGS))]
  UTILS_LDFLAGS        -- Optional extra LDFLAGS passed to utils link
                          process
                          [$(call utils_align_help,$(UTILS_LDFLAGS))]

::Installed::
  $$(stagingdir)/lib/libutils.so -- Shared library

::Bundled::
  $$(bundle_rootdir)/lib/libutils.so -- Shared library
endef

#################################################################################
## Configure logic
#################################################################################

define utils_defconfig_recipe
+$(Q)$(call ebuild_config_cmd, \
            $(UTILS_SRCDIR), \
            defconfig, \
            $(utils_make_args) DEFCONFIG:="$(UTILS_DEFCONFIG_FILE)")
endef

define utils_merge_config_recipe
+$(Q)$(call ebuild_merge_config_cmd, \
            $(UTILS_SRCDIR), \
            $(wildcard $(UTILS_CONFIG_FILES)), \
            $(utils_make_args))
endef

define utils_saveconfig_recipe
+$(Q)$(call ebuild_saveconfig_cmd,$(UTILS_SRCDIR),$(utils_make_args))
endef

define utils_guiconfig_recipe
+$(Q)$(call ebuild_guiconfig_cmd,$(UTILS_SRCDIR),$(utils_make_args))
endef

$(call ebuild_gen_config_rules, \
       $(UTILS_CONFIG_FILES), \
       utils_defconfig_recipe, \
       utils_merge_config_recipe, \
       utils_saveconfig_recipe, \
       utils_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define utils_build_recipe
+$(Q)$(call utils_make_cmd,build)
endef

$(call ebuild_gen_build_rule,utils_build_recipe)

################################################################################
# Clean logic
################################################################################

define utils_clean_recipe
+$(Q)$(call utils_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,utils_clean_recipe)

################################################################################
# Install logic
################################################################################

define utils_install_recipe
+$(Q)$(call utils_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,utils_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define utils_uninstall_recipe
+$(Q)$(call utils_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,utils_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define utils_bundle_recipe
+$(Q)$(call bundle_lib_cmd,$(stagingdir)/lib/libutils.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_bundle_rule,utils_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define utils_drop_recipe
+$(Q)$(call drop_lib_cmd,$(stagingdir)/lib/libutils.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_drop_rule,utils_drop_recipe)
