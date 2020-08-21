include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/kbuild.mk

# Interrupt processing when mandatory platform settings are missing.
$(call dieon_undef_or_empty,LINUX_SRCDIR)
$(call dieon_undef_or_empty,LINUX_CROSS_COMPILE)
$(call dieon_undef_or_empty,LINUX_ARCH)
$(call dieon_undef_or_empty,LINUX_DEFCONFIG)
$(call dieon_undef_or_empty,LINUX_DEVICETREE)

# Additional linux specific make arguments given to kbuild commands
linux_make_args := ARCH:=$(LINUX_ARCH) CROSS_COMPILE:=$(LINUX_CROSS_COMPILE)

define linux_make_cmd
$(call kbuild_make_cmd,$(LINUX_SRCDIR),$(1),$(linux_make_args) $(2))
endef

# Declare device tree
linux_dtb := $(LINUX_DEVICETREE).dtb

################################################################################
# This module help message
################################################################################

define module_help
Build Linux kernel images, modules and device firmwares as required by platform.

::Configuration variables::
  LINUX_SRCDIR           -- Path to Linux source tree root directory
                            [$(LINUX_SRCDIR)]
  LINUX_CROSS_COMPILE    -- Path to Linux cross compiling tool chain
                            [$(LINUX_CROSS_COMPILE)]
  LINUX_ARCH             -- Linux architecture to build for
                            [$(LINUX_ARCH)]
  LINUX_DEFCONFIG        -- Default Linux build configuration target
                            [$(LINUX_DEFCONFIG)]
  LINUX_DEVICETREE       -- Default Linux device tree name target
                            [$(LINUX_DEVICETREE)]
  LINUX_CONFIG_FILES     -- Additional Linux build configuration files merged
                            with current configuration
                            [$(LINUX_CONFIG_FILES)]
  LINUX_INSTALL_FIRMWARE -- Request firmware install if set to \'y\'
  LINUX_PLATFORM_HELP    -- Platform specific help message
$(LINUX_PLATFORM_HELP)
::Installed::
  $$(stagingdir)/lib/modules     -- Linux modules FS hierarchy
  $$(stagingdir)/lib/firmware    -- Linux firmware FS hierarchy
  $$(stagingdir)/boot/vmlinux    -- Boot\'able uncompressed Linux image
  $$(stagingdir)/boot/zImage     -- Boot\'able compressed Linux image
  $$(stagingdir)/boot/System.map -- Linux built-in symbol table

::Bundled::
  $$(bundledir)/boot/zImage       -- Boot\'able compressed Linux image
  $$(bundle_rootdir)/lib/modules  -- Linux modules target FS hierarchy
  $$(bundle_rootdir)/lib/firmware -- Linux firmware target FS hierarchy
endef

################################################################################
# Configure logic
################################################################################

define linux_defconfig_recipe
+$(Q)$(call kbuild_config_cmd, \
            $(LINUX_SRCDIR), \
            $(LINUX_DEFCONFIG), \
            $(linux_make_args))
endef

define linux_merge_config_recipe
+$(Q)$(call kbuild_merge_config_cmd, \
            $(LINUX_SRCDIR), \
            $(wildcard $(LINUX_CONFIG_FILES)), \
            $(linux_make_args))
endef

define linux_saveconfig_recipe
+$(Q)$(call kbuild_saveconfig_cmd,$(LINUX_SRCDIR),$(linux_make_args))
endef

define linux_guiconfig_recipe
+$(Q)$(call kbuild_guiconfig_cmd,$(LINUX_SRCDIR),$(linux_make_args))
endef

$(call kbuild_gen_config_rules, \
       $(LINUX_CONFIG_FILES), \
       linux_defconfig_recipe, \
       linux_merge_config_recipe, \
       linux_saveconfig_recipe, \
       linux_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define linux_build_recipe
+$(Q)$(call linux_make_cmd,zImage modules $(linux_dtb))
endef

$(call kbuild_gen_build_rule,linux_build_recipe)

################################################################################
# Clean logic
################################################################################

ifeq ($(kbuild_configured),y)

define linux_clean_recipe
+$(Q)$(call linux_make_cmd,clean)
endef

$(call kbuild_gen_clean_rule,linux_clean_recipe)

endif

################################################################################
# Install logic
################################################################################

linux_install_firmware := $(if $(filter _y_,_$(LINUX_INSTALL_FIRMWARE)_), \
                               firmware_install)

define linux_install_recipe
+$(Q)$(call linux_make_cmd, \
            modules_install headers_install $(linux_install_firmware), \
            INSTALL_PATH:="$(module_installdir)" \
            INSTALL_MOD_PATH:="$(module_installdir)" \
            INSTALL_FW_PATH:="$(module_installdir)/lib/firmware" \
            INSTALL_HDR_PATH:="$(module_installdir)/usr")
$(Q)$(call mirror_cmd,$(module_installdir)/,$(stagingdir))
$(Q)$(call mkdir_cmd,$(stagingdir)/boot)
$(Q)$(call lnck_cmd,$(module_builddir)/vmlinux,$(stagingdir)/boot/vmlinux)
$(Q)$(call lnck_cmd, \
           $(module_builddir)/arch/$(LINUX_ARCH)/boot/zImage, \
           $(module_builddir)/zImage)
$(Q)$(call lnck_cmd,$(module_builddir)/System.map,$(stagingdir)/boot/System.map)
endef

$(call kbuild_gen_install_rule,linux_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define linux_uninstall_recipe
$(Q)$(call rmf_cmd,$(stagingdir)/boot/System.map)
$(Q)$(call rmf_cmd,$(stagingdir)/boot/zImage)
$(Q)$(call rmf_cmd,$(stagingdir)/boot/vmlinux)
$(Q)$(call unmirror_cmd,$(module_installdir),$(stagingdir))
$(Q)$(call rmrf_cmd,$(module_installdir))
endef

$(call kbuild_gen_uninstall_rule,linux_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define linux_bundle_recipe
+$(Q)$(call fake_root_cmd, \
            $(bundle_fake_root_env), \
            $(call linux_make_cmd, \
                   modules_install $(linux_install_firmware), \
                   INSTALL_MOD_STRIP:=1 \
                   INSTALL_PATH:="$(bundle_rootdir)" \
                   INSTALL_MOD_PATH:="$(bundle_rootdir)" \
                   INSTALL_FW_PATH:="$(bundle_rootdir)/lib/firmware"))
$(Q)$(call fake_root_cmd, \
           $(bundle_fake_root_env), \
           rm -f $(bundle_rootdir)/lib/modules/*/build)
$(Q)$(call fake_root_cmd, \
           $(bundle_fake_root_env), \
           rm -f $(bundle_rootdir)/lib/modules/*/source)
$(Q)$(call lnck_cmd, \
           $(module_builddir)/arch/$(LINUX_ARCH)/boot/zImage, \
           $(bundledir)/zImage)
$(Q)$(call lnck_cmd, \
           $(module_builddir)/arch/$(LINUX_ARCH)/boot/dts/$(linux_dtb), \
           $(bundledir)/linux.dtb)
endef

$(call kbuild_gen_bundle_rule,linux_bundle_recipe)

################################################################################
# drop logic
################################################################################

define linux_drop_recipe
$(Q)$(call rmf_cmd,$(bundledir)/linux.dtb)
$(Q)$(call rmf_cmd,$(bundledir)/zImage)
$(Q)$(call fake_root_cmd, \
           $(bundle_fake_root_env), \
           $(call unmirror_cmd,$(module_installdir),$(bundle_rootdir)))
endef

$(call kbuild_gen_drop_rule,linux_drop_recipe)

################################################################################
# Various Linux build native targets
################################################################################

define linux_native_recipe
+$(Q)$(call linux_make_cmd,$(1))
endef

$(call kbuild_gen_native_rules,linux_native_recipe)
