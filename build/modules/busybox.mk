include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/kbuild.mk

$(call gen_module_depends,libcrypt)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,BUSYBOX_SRCDIR)
# Interrupt processing if platform specified no toolchain.
$(call dieon_undef_or_empty,BUSYBOX_CROSS_COMPILE)
# Interrupt processing if platform specified no target architecture.
$(call dieon_undef_or_empty,BUSYBOX_ARCH)
# Interrupt processing if platform specified no default build configuration.
$(call dieon_undef_or_empty,BUSYBOX_DEFCONFIG_FILE)

busybox_cflags  := $(BUSYBOX_CFLAGS) -I$(stagingdir)/include
busybox_ldflags := $(BUSYBOX_LDFLAGS) -L$(stagingdir)/lib

# Additional Busybox specific make arguments given to kbuild commands
busybox_make_args := ARCH:=$(BUSYBOX_ARCH) \
                     CROSS_COMPILE:=$(BUSYBOX_CROSS_COMPILE) \
                     EXTRA_CFLAGS:="$(busybox_cflags)" \
                     EXTRA_LDFLAGS:="$(busybox_ldflags)"

define busybox_make_cmd
$(call kbuild_make_cmd,$(BUSYBOX_SRCDIR),$(1),$(busybox_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define busybox_align_help
$(subst $(space),$(newline)                             ,$(1))
endef

define module_help
Build Busybox tiny utilites as required by platform.

::Configuration variables::
  BUSYBOX_SRCDIR         -- Path to Busybox source tree root directory
                            [$(BUSYBOX_SRCDIR)]
  BUSYBOX_CROSS_COMPILE  -- Path to Busybox cross compiling tool chain
                            [$(BUSYBOX_CROSS_COMPILE)]
  BUSYBOX_CFLAGS         -- Optional extra CFLAGS passed to Busybox compile
                            process
                            [$(call busybox_align_help,$(BUSYBOX_CFLAGS))]
  BUSYBOX_LDFLAGS        -- Optional extra LDFLAGS passed to Busybox link
                            process
                            [$(call busybox_align_help,$(BUSYBOX_LDFLAGS))]
  BUSYBOX_ARCH           -- Busybox architecture to build for
                            [$(BUSYBOX_ARCH)]
  BUSYBOX_DEFCONFIG_FILE -- Default Busybox build configuration file path
                            [$(BUSYBOX_DEFCONFIG_FILE)]
  BUSYBOX_CONFIG_FILES   -- Additional Busybox build configuration files merged
                            with current configuration
                            [$(BUSYBOX_CONFIG_FILES)]
  BUSYBOX_PLATFORM_HELP  -- Platform specific help message
$(BUSYBOX_PLATFORM_HELP)
::Installed::
  $$(stagingdir)/bin/busybox -- Busybox binary
  $$(stagingdir)/bin/*       -- Busybox applets
  $$(stagingdir)/sbin/*      -- Busybox applets

::Bundled::
  $$(bundle_rootdir)/bin/busybox -- Busybox binary
  $$(bundle_rootdir)/bin/*       -- Busybox applets
  $$(bundle_rootdir)/sbin/*      -- Busybox applets
endef

################################################################################
# Configure logic
################################################################################

# Busybox does not support usual Kconfig defconfig operation. Simply copy
# platform build configuration file to current build configuration file
# expeceted location.
define busybox_defconfig_recipe
$(Q)$(call cp_cmd,$(BUSYBOX_DEFCONFIG_FILE),$(module_builddir)/.config)
+$(Q)$(call kbuild_config_cmd, \
            $(BUSYBOX_SRCDIR), \
            oldconfig, \
            $(busybox_make_args))
endef

define busybox_merge_config_recipe
+$(Q)$(call kbuild_merge_config_cmd, \
            $(BUSYBOX_SRCDIR), \
            $(wildcard $(BUSYBOX_CONFIG_FILES)), \
            $(busybox_make_args))
endef

# Busybox does not support usual Kconfig savedefconfig operation. Simply copy
# backup build configuration file into build directory.
define busybox_saveconfig_recipe
$(Q)$(call cp_cmd,$(module_builddir)/.config,$(module_builddir)/defconfig)
endef

define busybox_guiconfig_recipe
+$(Q)$(call kbuild_guiconfig_cmd, \
            $(BUSYBOX_SRCDIR), \
            $(busybox_make_args))
endef

# Busybox does not support merging of Kconfig files. This why Kbuild merge
# config recipe and additional configuration files are not defined.
#
# TODO: borrow merge_config.sh script from Linux or U-Boot source trees
# and implement build configurations merging.
$(call kbuild_gen_config_rules, \
       $(BUSYBOX_CONFIG_FILES), \
       busybox_defconfig_recipe, \
       busybox_merge_config_recipe, \
       busybox_saveconfig_recipe, \
       busybox_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define busybox_build_recipe
+$(Q)$(call busybox_make_cmd,all)
endef

$(call kbuild_gen_build_rule,busybox_build_recipe)

################################################################################
# Clean logic
################################################################################

ifeq ($(kbuild_configured),y)

define busybox_clean_recipe
+$(Q)$(call busybox_make_cmd,clean)
endef

$(call kbuild_gen_clean_rule,busybox_clean_recipe)

endif

################################################################################
# Install logic
################################################################################

# By default, Busybox Kbuild install a stripped binary version.
# Override default behaviour by installing the unstripped version into staging
# area instead to allow ease debugging operations.
define busybox_install_recipe
+$(Q)$(call busybox_make_cmd,install,CONFIG_PREFIX:=$(stagingdir))
$(Q)$(call install_cmd, \
           -m755, \
           $(module_builddir)/busybox_unstripped, \
           $(stagingdir)/bin/busybox)
endef

$(call kbuild_gen_install_rule,busybox_install_recipe)

################################################################################
# Uninstall logic
################################################################################

ifeq ($(kbuild_configured),y)

define busybox_uninstall_recipe
+$(Q)$(call busybox_make_cmd,uninstall,CONFIG_PREFIX:=$(stagingdir))
endef

$(call kbuild_gen_uninstall_rule,busybox_uninstall_recipe)

endif

################################################################################
# Bundle logic
################################################################################

define busybox_bundle_recipe
+$(Q)$(call fake_root_cmd, \
            $(bundle_fake_root_env), \
            $(call busybox_make_cmd,install,CONFIG_PREFIX:=$(bundle_rootdir)))
$(Q)$(call log_action,CHMOD,$(bundle_rootdir)/bin/busybox)
$(Q)$(call fake_root_cmd, \
           $(bundle_fake_root_env), \
           chmod u+s $(bundle_rootdir)/bin/busybox)
endef

$(call kbuild_gen_bundle_rule,busybox_bundle_recipe)

################################################################################
# Drop logic
################################################################################

ifeq ($(kbuild_configured),y)

define busybox_drop_recipe
+$(Q)$(call fake_root_cmd, \
            $(bundle_fake_root_env), \
            $(call busybox_make_cmd,uninstall,CONFIG_PREFIX:=$(bundle_rootdir)))
endef

$(call kbuild_gen_drop_rule,busybox_drop_recipe)

endif

################################################################################
# Various Busybox build native targets
################################################################################

define busybox_native_recipe
+$(Q)$(call busybox_make_cmd,$(1))
endef

$(call kbuild_gen_native_rules,busybox_native_recipe)
