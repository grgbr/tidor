include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call gen_module_depends,busybox)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,TINIT_SRCDIR)
# Interrupt processing if platform specified no toolchain.
$(call dieon_undef_or_empty,TINIT_CROSS_COMPILE)

tinit_cflags  := $(TINIT_CFLAGS) -I$(stagingdir)/include
tinit_ldflags := $(TINIT_LDFLAGS) -L$(stagingdir)/lib

# Additional Tinit specific make arguments given to ebuild commands
tinit_make_args := CROSS_COMPILE:="$(TINIT_CROSS_COMPILE)" \
                   PREFIX:=/ \
                   EXTRA_CFLAGS:="$(tinit_cflags)" \
                   EXTRA_LDFLAGS:="$(tinit_ldflags)"

define tinit_make_cmd
$(call ebuild_make_cmd,$(TINIT_SRCDIR),$(1),$(tinit_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define tinit_align_help
$(subst $(space),$(newline)                          ,$(strip $(1)))
endef

define module_help
Build Tinit, a busybox runit / glibc based init.

::Configuration variables::
  TINIT_SRCDIR        -- Path to Tinit source tree root directory
                         [$(TINIT_SRCDIR)]
  TINIT_CROSS_COMPILE -- Path to Tinit cross compiling tool chain
                         [$(TINIT_CROSS_COMPILE)]
  TINIT_CFLAGS        -- Optional extra CFLAGS passed to Tinit compile
                         process
                         [$(call tinit_align_help,$(TINIT_CFLAGS))]
  TINIT_LDFLAGS       -- Optional extra LDFLAGS passed to Tinit link
                         process
                         [$(call tinit_align_help,$(TINIT_LDFLAGS))]

::Installed::
  $$(stagingdir)/sbin/init
  $$(stagingdir)/libexec/tinit/sysinit
  $$(stagingdir)/libexec/tinit/shutdown

::Bundled::
  $$(bundle_rootdir)/sbin/init
  $$(bundle_rootdir)/libexec/tinit/sysinit
  $$(bundle_rootdir)/libexec/tinit/shutdown
endef

#################################################################################
## Configure logic
#################################################################################
#
## Tinit does not support usual Kconfig defconfig operation. Simply copy
## platform build configuration file to current build configuration file
## expeceted location.
#define tinit_defconfig_recipe
#$(Q)$(call cp_cmd,$(TINIT_DEFCONFIG_FILE),$(module_builddir)/.config)
#+$(Q)$(call kbuild_config_cmd, \
#            $(TINIT_SRCDIR), \
#            oldconfig, \
#            $(tinit_make_args))
#endef
#
#define tinit_merge_config_recipe
#+$(Q)$(call kbuild_merge_config_cmd, \
#            $(TINIT_SRCDIR), \
#            $(wildcard $(TINIT_CONFIG_FILES)), \
#            $(tinit_make_args))
#endef
#
## Tinit does not support usual Kconfig savedefconfig operation. Simply copy
## backup build configuration file into build directory.
#define tinit_saveconfig_recipe
#$(Q)$(call cp_cmd,$(module_builddir)/.config,$(module_builddir)/defconfig)
#endef
#
#define tinit_guiconfig_recipe
#+$(Q)$(call kbuild_guiconfig_cmd, \
#            $(TINIT_SRCDIR), \
#            $(tinit_make_args))
#endef
#
## Tinit does not support merging of Kconfig files. This why Kbuild merge
## config recipe and additional configuration files are not defined.
##
## TODO: borrow merge_config.sh script from Linux or U-Boot source trees
## and implement build configurations merging.
#$(call kbuild_gen_config_rules, \
#       $(TINIT_CONFIG_FILES), \
#       tinit_defconfig_recipe, \
#       tinit_merge_config_recipe, \
#       tinit_saveconfig_recipe, \
#       tinit_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define tinit_build_recipe
+$(Q)$(call tinit_make_cmd,build)
endef

$(call ebuild_gen_build_rule,tinit_build_recipe)

################################################################################
# Clean logic
################################################################################

define tinit_clean_recipe
+$(Q)$(call tinit_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,tinit_clean_recipe)

################################################################################
# Install logic
################################################################################

define tinit_install_recipe
+$(Q)$(call tinit_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,tinit_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define tinit_uninstall_recipe
+$(Q)$(call tinit_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,tinit_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define tinit_bundle_recipe
+$(Q)$(call fake_root_cmd, \
            $(bundle_fake_root_env), \
            $(call tinit_make_cmd,install-strip,DESTDIR:=$(bundle_rootdir)))
endef

$(call ebuild_gen_bundle_rule,tinit_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define tinit_drop_recipe
+$(Q)$(call fake_root_cmd, \
            $(bundle_fake_root_env), \
            $(call tinit_make_cmd,uninstall,DESTDIR:=$(bundle_rootdir)))
endef

$(call ebuild_gen_drop_rule,tinit_drop_recipe)
