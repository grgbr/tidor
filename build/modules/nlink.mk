include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call gen_module_depends,utils)

$(call dieon_undef_or_empty,NLINK_SRCDIR)
$(call dieon_undef_or_empty,NLINK_EBUILDDIR)
$(call dieon_undef_or_empty,NLINK_CROSS_COMPILE)

nlink_cflags  := $(NLINK_CFLAGS) -I$(stagingdir)/usr/include
nlink_ldflags := $(NLINK_LDFLAGS) -L$(stagingdir)/lib

# Additional nlink specific make arguments given to ebuild commands
nlink_make_args := \
	EBUILDDIR:="$(NLINK_EBUILDDIR)" \
	CROSS_COMPILE:="$(NLINK_CROSS_COMPILE)" \
	PREFIX:=/ \
	INCLUDEDIR:=/usr/include \
	EXTRA_CFLAGS:="$(nlink_cflags)" \
	EXTRA_LDFLAGS:="$(nlink_ldflags)" \
	$(NLINK_PKGCONF)

define nlink_make_cmd
$(call ebuild_make_cmd,$(NLINK_SRCDIR),$(1),$(nlink_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define nlink_align_help
$(subst $(space),$(newline)                           ,$(strip $(1)))
endef

define module_help
Build nlink, a busybox runit / glibc based init.

::Configuration variables::
  NLINK_SRCDIR         -- Path to nlink source tree root directory
                          [$(NLINK_SRCDIR)]
  NLINK_EBUILDDIR      -- Path to ebuild source tree root directory
                          [$(NLINK_EBUILDDIR)]
  NLINK_DEFCONFIG_FILE -- Optional default build configuration file path
                          [$(NLINK_DEFCONFIG_FILE)]
  NLINK_CONFIG_FILES   -- Additional configuration files merged with current
                          configuration
                          [$(NLINK_CONFIG_FILES)]
  NLINK_CROSS_COMPILE  -- Path to nlink cross compiling tool chain
                          [$(NLINK_CROSS_COMPILE)]
  NLINK_PKGCONF        -- pkg-config environment passed to nlink build process
                          [$(call nlink_align_help,$(NLINK_PKGCONF))]
  NLINK_CFLAGS         -- Optional extra CFLAGS passed to nlink compile
                          process
                          [$(call nlink_align_help,$(NLINK_CFLAGS))]
  NLINK_LDFLAGS        -- Optional extra LDFLAGS passed to nlink link
                          process
                          [$(call nlink_align_help,$(NLINK_LDFLAGS))]

::Installed::
  $$(stagingdir)/lib/libnlink.so -- Shared library

::Bundled::
  $$(bundle_rootdir)/lib/libnlink.so -- Shared library
endef

#################################################################################
## Configure logic
#################################################################################

define nlink_defconfig_recipe
+$(Q)$(call ebuild_config_cmd, \
            $(NLINK_SRCDIR), \
            defconfig, \
            $(nlink_make_args) DEFCONFIG:="$(NLINK_DEFCONFIG_FILE)")
endef

define nlink_merge_config_recipe
+$(Q)$(call ebuild_merge_config_cmd, \
            $(NLINK_SRCDIR), \
            $(wildcard $(NLINK_CONFIG_FILES)), \
            $(nlink_make_args))
endef

define nlink_saveconfig_recipe
+$(Q)$(call ebuild_saveconfig_cmd,$(NLINK_SRCDIR),$(nlink_make_args))
endef

define nlink_guiconfig_recipe
+$(Q)$(call ebuild_guiconfig_cmd,$(NLINK_SRCDIR),$(nlink_make_args))
endef

$(call ebuild_gen_config_rules, \
       $(NLINK_CONFIG_FILES), \
       nlink_defconfig_recipe, \
       nlink_merge_config_recipe, \
       nlink_saveconfig_recipe, \
       nlink_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define nlink_build_recipe
+$(Q)$(call nlink_make_cmd,build)
endef

$(call ebuild_gen_build_rule,nlink_build_recipe)

################################################################################
# Clean logic
################################################################################

define nlink_clean_recipe
+$(Q)$(call nlink_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,nlink_clean_recipe)

################################################################################
# Install logic
################################################################################

define nlink_install_recipe
+$(Q)$(call nlink_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,nlink_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define nlink_uninstall_recipe
+$(Q)$(call nlink_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,nlink_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define nlink_bundle_recipe
+$(Q)$(call bundle_lib_cmd,$(stagingdir)/lib/libnlink.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_bundle_rule,nlink_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define nlink_drop_recipe
+$(Q)$(call drop_lib_cmd,$(stagingdir)/lib/libnlink.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_drop_rule,nlink_drop_recipe)
