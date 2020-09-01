include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call gen_module_depends,libdb utils $(filter btrace,$(MODULES)))

$(call dieon_undef_or_empty,KVSTORE_SRCDIR)
$(call dieon_undef_or_empty,KVSTORE_EBUILDDIR)
$(call dieon_undef_or_empty,KVSTORE_CROSS_COMPILE)

kvstore_cflags  := $(KVSTORE_CFLAGS) -I$(stagingdir)/usr/include
kvstore_ldflags := $(KVSTORE_LDFLAGS) \
                   -L$(stagingdir)/lib \
                   -Wl,-rpath-link,$(stagingdir)/lib

# Additional kvstore specific make arguments given to ebuild commands
kvstore_make_args := \
	EBUILDDIR:="$(KVSTORE_EBUILDDIR)" \
	CROSS_COMPILE:="$(KVSTORE_CROSS_COMPILE)" \
	PREFIX:=/ \
	INCLUDEDIR:=/usr/include \
	EXTRA_CFLAGS:="$(kvstore_cflags)" \
	EXTRA_LDFLAGS:="$(kvstore_ldflags)" \
	$(KVSTORE_PKGCONF)

define kvstore_make_cmd
$(call ebuild_make_cmd,$(KVSTORE_SRCDIR),$(1),$(kvstore_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define kvstore_align_help
$(subst $(space),$(newline)                           ,$(strip $(1)))
endef

define module_help
Build kvstore, a busybox runit / glibc based init.

::Configuration variables::
  KVSTORE_SRCDIR         -- Path to kvstore source tree root directory
                          [$(KVSTORE_SRCDIR)]
  KVSTORE_EBUILDDIR      -- Path to ebuild source tree root directory
                          [$(KVSTORE_EBUILDDIR)]
  KVSTORE_DEFCONFIG_FILE -- Optional default build configuration file path
                          [$(KVSTORE_DEFCONFIG_FILE)]
  KVSTORE_CONFIG_FILES   -- Additional configuration files merged with current
                          configuration
                          [$(KVSTORE_CONFIG_FILES)]
  KVSTORE_CROSS_COMPILE  -- Path to kvstore cross compiling tool chain
                          [$(KVSTORE_CROSS_COMPILE)]
  KVSTORE_PKGCONF        -- pkg-config environment passed to kvstore build process
                          [$(call kvstore_align_help,$(KVSTORE_PKGCONF))]
  KVSTORE_CFLAGS         -- Optional extra CFLAGS passed to kvstore compile
                          process
                          [$(call kvstore_align_help,$(KVSTORE_CFLAGS))]
  KVSTORE_LDFLAGS        -- Optional extra LDFLAGS passed to kvstore link
                          process
                          [$(call kvstore_align_help,$(KVSTORE_LDFLAGS))]

::Installed::
  $$(stagingdir)/lib/libkvstore.so -- Shared library

::Bundled::
  $$(bundle_rootdir)/lib/libkvstore.so -- Shared library
endef

#################################################################################
## Configure logic
#################################################################################

define kvstore_defconfig_recipe
+$(Q)$(call ebuild_config_cmd, \
            $(KVSTORE_SRCDIR), \
            defconfig, \
            $(kvstore_make_args) DEFCONFIG:="$(KVSTORE_DEFCONFIG_FILE)")
endef

define kvstore_merge_config_recipe
+$(Q)$(call ebuild_merge_config_cmd, \
            $(KVSTORE_SRCDIR), \
            $(wildcard $(KVSTORE_CONFIG_FILES)), \
            $(kvstore_make_args))
endef

define kvstore_saveconfig_recipe
+$(Q)$(call ebuild_saveconfig_cmd,$(KVSTORE_SRCDIR),$(kvstore_make_args))
endef

define kvstore_guiconfig_recipe
+$(Q)$(call ebuild_guiconfig_cmd,$(KVSTORE_SRCDIR),$(kvstore_make_args))
endef

$(call ebuild_gen_config_rules, \
       $(KVSTORE_CONFIG_FILES), \
       kvstore_defconfig_recipe, \
       kvstore_merge_config_recipe, \
       kvstore_saveconfig_recipe, \
       kvstore_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define kvstore_build_recipe
+$(Q)$(call kvstore_make_cmd,build)
endef

$(call ebuild_gen_build_rule,kvstore_build_recipe)

################################################################################
# Clean logic
################################################################################

define kvstore_clean_recipe
+$(Q)$(call kvstore_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,kvstore_clean_recipe)

################################################################################
# Install logic
################################################################################

define kvstore_install_recipe
+$(Q)$(call kvstore_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,kvstore_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define kvstore_uninstall_recipe
+$(Q)$(call kvstore_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,kvstore_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define kvstore_bundle_recipe
+$(Q)$(call bundle_lib_cmd,$(stagingdir)/lib/libkvstore.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_bundle_rule,kvstore_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define kvstore_drop_recipe
+$(Q)$(call drop_lib_cmd,$(stagingdir)/lib/libkvstore.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_drop_rule,kvstore_drop_recipe)
