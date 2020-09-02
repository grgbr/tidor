include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call gen_module_depends,utils)

$(call dieon_undef_or_empty,CLUI_SRCDIR)
$(call dieon_undef_or_empty,CLUI_EBUILDDIR)
$(call dieon_undef_or_empty,CLUI_CROSS_COMPILE)

clui_cflags  := $(CLUI_CFLAGS) -I$(stagingdir)/usr/include
clui_ldflags := $(CLUI_LDFLAGS) \
                -L$(stagingdir)/lib \
                -Wl,-rpath-link,$(stagingdir)/lib

# Additional clui specific make arguments given to ebuild commands
clui_make_args := \
	EBUILDDIR:="$(CLUI_EBUILDDIR)" \
	CROSS_COMPILE:="$(CLUI_CROSS_COMPILE)" \
	PREFIX:=/ \
	INCLUDEDIR:=/usr/include \
	EXTRA_CFLAGS:="$(clui_cflags)" \
	EXTRA_LDFLAGS:="$(clui_ldflags)" \
	$(CLUI_PKGCONF)

define clui_make_cmd
$(call ebuild_make_cmd,$(CLUI_SRCDIR),$(1),$(clui_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define clui_align_help
$(subst $(space),$(newline)                          ,$(strip $(1)))
endef

define module_help
Build clui, a busybox runit / glibc based init.

::Configuration variables::
  CLUI_SRCDIR         -- Path to clui source tree root directory
                         [$(CLUI_SRCDIR)]
  CLUI_EBUILDDIR      -- Path to ebuild source tree root directory
                         [$(CLUI_EBUILDDIR)]
  CLUI_DEFCONFIG_FILE -- Optional default build configuration file path
                         [$(CLUI_DEFCONFIG_FILE)]
  CLUI_CONFIG_FILES   -- Additional configuration files merged with current
                         configuration
                         [$(CLUI_CONFIG_FILES)]
  CLUI_CROSS_COMPILE  -- Path to clui cross compiling tool chain
                         [$(CLUI_CROSS_COMPILE)]
  CLUI_PKGCONF        -- pkg-config environment passed to clui build process
                         [$(call clui_align_help,$(CLUI_PKGCONF))]
  CLUI_CFLAGS         -- Optional extra CFLAGS passed to clui compile
                         process
                         [$(call clui_align_help,$(CLUI_CFLAGS))]
  CLUI_LDFLAGS        -- Optional extra LDFLAGS passed to clui link
                         process
                         [$(call clui_align_help,$(CLUI_LDFLAGS))]

::Installed::
  $$(stagingdir)/lib/libclui.so -- Shared library

::Bundled::
  $$(bundle_rootdir)/lib/libclui.so -- Shared library
endef

#################################################################################
## Configure logic
#################################################################################

define clui_defconfig_recipe
+$(Q)$(call ebuild_config_cmd, \
            $(CLUI_SRCDIR), \
            defconfig, \
            $(clui_make_args) DEFCONFIG:="$(CLUI_DEFCONFIG_FILE)")
endef

define clui_merge_config_recipe
+$(Q)$(call ebuild_merge_config_cmd, \
            $(CLUI_SRCDIR), \
            $(wildcard $(CLUI_CONFIG_FILES)), \
            $(clui_make_args))
endef

define clui_saveconfig_recipe
+$(Q)$(call ebuild_saveconfig_cmd,$(CLUI_SRCDIR),$(clui_make_args))
endef

define clui_guiconfig_recipe
+$(Q)$(call ebuild_guiconfig_cmd,$(CLUI_SRCDIR),$(clui_make_args))
endef

$(call ebuild_gen_config_rules, \
       $(CLUI_CONFIG_FILES), \
       clui_defconfig_recipe, \
       clui_merge_config_recipe, \
       clui_saveconfig_recipe, \
       clui_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define clui_build_recipe
+$(Q)$(call clui_make_cmd,build)
endef

$(call ebuild_gen_build_rule,clui_build_recipe)

################################################################################
# Clean logic
################################################################################

define clui_clean_recipe
+$(Q)$(call clui_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,clui_clean_recipe)

################################################################################
# Install logic
################################################################################

define clui_install_recipe
+$(Q)$(call clui_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,clui_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define clui_uninstall_recipe
+$(Q)$(call clui_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,clui_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define clui_bundle_recipe
+$(Q)$(call bundle_lib_cmd,$(stagingdir)/lib/libclui.so,$(bundle_rootdir)/lib)
endef


$(call ebuild_gen_bundle_rule,clui_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define clui_drop_recipe
+$(Q)$(call drop_lib_cmd,$(stagingdir)/lib/libclui.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_drop_rule,clui_drop_recipe)
