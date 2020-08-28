include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call gen_module_depends, \
       nlink kvstore clui utils $(if $(filter,btrace,$(MODULES)),btrace))

$(call dieon_undef_or_empty,NWIF_SRCDIR)
$(call dieon_undef_or_empty,NWIF_EBUILDDIR)
$(call dieon_undef_or_empty,NWIF_CROSS_COMPILE)

nwif_cflags  := $(NWIF_CFLAGS) -I$(stagingdir)/usr/include
nwif_ldflags := $(NWIF_LDFLAGS) \
                -L$(stagingdir)/lib \
                -Wl,-rpath-link,$(stagingdir)/lib

# Additional nwif specific make arguments given to ebuild commands
nwif_make_args := \
	EBUILDDIR:="$(NWIF_EBUILDDIR)" \
	CROSS_COMPILE:="$(NWIF_CROSS_COMPILE)" \
	PREFIX:=/ \
	INCLUDEDIR:=/usr/include \
	EXTRA_CFLAGS:="$(nwif_cflags)" \
	EXTRA_LDFLAGS:="$(nwif_ldflags)" \
	$(NWIF_PKGCONF)

define nwif_make_cmd
$(call ebuild_make_cmd,$(NWIF_SRCDIR),$(1),$(nwif_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define nwif_align_help
$(subst $(space),$(newline)                           ,$(strip $(1)))
endef

define module_help
Build nwif, a busybox runit / glibc based init.

::Configuration variables::
  NWIF_SRCDIR         -- Path to nwif source tree root directory
                         [$(NWIF_SRCDIR)]
  NWIF_EBUILDDIR      -- Path to ebuild source tree root directory
                         [$(NWIF_EBUILDDIR)]
  NWIF_DEFCONFIG_FILE -- Optional default build configuration file path
                         [$(NWIF_DEFCONFIG_FILE)]
  NWIF_CONFIG_FILES   -- Additional configuration files merged with current
                         configuration
                         [$(NWIF_CONFIG_FILES)]
  NWIF_CROSS_COMPILE  -- Path to nwif cross compiling tool chain
                         [$(NWIF_CROSS_COMPILE)]
  NWIF_PKGCONF        -- pkg-config environment passed to nwif build process
                         [$(call nwif_align_help,$(NWIF_PKGCONF))]
  NWIF_CFLAGS         -- Optional extra CFLAGS passed to nwif compile
                         process
                         [$(call nwif_align_help,$(NWIF_CFLAGS))]
  NWIF_LDFLAGS        -- Optional extra LDFLAGS passed to nwif link
                         process
                         [$(call nwif_align_help,$(NWIF_LDFLAGS))]

::Installed::
  $$(stagingdir)/bin/nwif_conf  -- Configuration utility
  $$(stagingdir)/lib/libnwif.so -- Shared library

::Bundled::
  $$(bundle_rootdir)/bin/nwif_conf  -- Configuration utility
  $$(bundle_rootdir)/lib/libnwif.so -- Shared library
endef

#################################################################################
## Configure logic
#################################################################################

define nwif_defconfig_recipe
+$(Q)$(call ebuild_config_cmd, \
            $(NWIF_SRCDIR), \
            defconfig, \
            $(nwif_make_args) DEFCONFIG:="$(NWIF_DEFCONFIG_FILE)")
endef

define nwif_merge_config_recipe
+$(Q)$(call ebuild_merge_config_cmd, \
            $(NWIF_SRCDIR), \
            $(wildcard $(NWIF_CONFIG_FILES)), \
            $(nwif_make_args))
endef

define nwif_saveconfig_recipe
+$(Q)$(call ebuild_saveconfig_cmd,$(NWIF_SRCDIR),$(nwif_make_args))
endef

define nwif_guiconfig_recipe
+$(Q)$(call ebuild_guiconfig_cmd,$(NWIF_SRCDIR),$(nwif_make_args))
endef

$(call ebuild_gen_config_rules, \
       $(NWIF_CONFIG_FILES), \
       nwif_defconfig_recipe, \
       nwif_merge_config_recipe, \
       nwif_saveconfig_recipe, \
       nwif_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define nwif_build_recipe
+$(Q)$(call nwif_make_cmd,build)
endef

$(call ebuild_gen_build_rule,nwif_build_recipe)

################################################################################
# Clean logic
################################################################################

define nwif_clean_recipe
+$(Q)$(call nwif_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,nwif_clean_recipe)

################################################################################
# Install logic
################################################################################

define nwif_install_recipe
+$(Q)$(call nwif_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,nwif_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define nwif_uninstall_recipe
+$(Q)$(call nwif_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,nwif_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define nwif_bundle_recipe
+$(Q)$(call bundle_lib_cmd,$(stagingdir)/lib/libnwif.so,$(bundle_rootdir)/lib)
+$(Q)$(call bundle_bin_cmd,$(stagingdir)/bin/nwif_conf,$(bundle_rootdir)/bin)
endef


$(call ebuild_gen_bundle_rule,nwif_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define nwif_drop_recipe
+$(Q)$(call drop_cmd,$(bundle_rootdir)/bin/nwif_conf)
+$(Q)$(call drop_lib_cmd,$(stagingdir)/lib/libnwif.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_drop_rule,nwif_drop_recipe)
