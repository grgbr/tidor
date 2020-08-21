include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/ebuild.mk

$(call gen_module_depends,elfutils)

$(call dieon_undef_or_empty,BTRACE_SRCDIR)
$(call dieon_undef_or_empty,BTRACE_EBUILDDIR)
$(call dieon_undef_or_empty,BTRACE_CROSS_COMPILE)

btrace_cflags  := $(BTRACE_CFLAGS) -I$(stagingdir)/usr/include
btrace_ldflags := $(BTRACE_LDFLAGS) -L$(stagingdir)/lib

# Additional btrace specific make arguments given to ebuild commands
btrace_make_args := \
	EBUILDDIR:="$(BTRACE_EBUILDDIR)" \
	CROSS_COMPILE:="$(BTRACE_CROSS_COMPILE)" \
	PREFIX:=/ \
	INCLUDEDIR:=/usr/include \
	EXTRA_CFLAGS:="$(btrace_cflags)" \
	EXTRA_LDFLAGS:="$(btrace_ldflags)" \
	$(BTRACE_PKGCONF)

define btrace_make_cmd
$(call ebuild_make_cmd,$(BTRACE_SRCDIR),$(1),$(btrace_make_args) $(2))
endef

################################################################################
# This module help message
################################################################################

define btrace_align_help
$(subst $(space),$(newline)                           ,$(strip $(1)))
endef

define module_help
Build btrace, an embeddedable stack trace library for quick and dirty
application crashes debugging.

::Configuration variables::
  BTRACE_SRCDIR         -- Path to btrace source tree root directory
                           [$(BTRACE_SRCDIR)]
  BTRACE_EBUILDDIR      -- Path to ebuild source tree root directory
                           [$(BTRACE_EBUILDDIR)]
  BTRACE_CROSS_COMPILE  -- Path to btrace cross compiling tool chain
                           [$(BTRACE_CROSS_COMPILE)]
  BTRACE_PKGCONF        -- pkg-config environment passed to btrace build process
                           [$(call btrace_align_help,$(BTRACE_PKGCONF))]
  BTRACE_CFLAGS         -- Optional extra CFLAGS passed to btrace compile
                           process
                           [$(call btrace_align_help,$(BTRACE_CFLAGS))]
  BTRACE_LDFLAGS        -- Optional extra LDFLAGS passed to btrace link
                           process
                           [$(call btrace_align_help,$(BTRACE_LDFLAGS))]

::Installed::
  $$(stagingdir)/lib/libbtrace.so           -- Shared library
  $$(stagingdir)/lib/pkgconfig/libbtrace.pc -- pkg-config metadata file.

::Bundled::
  $$(bundle_rootdir)/lib/libbtrace.so -- Shared library
endef

#################################################################################
## Configure logic
#################################################################################

#define btrace_defconfig_recipe
#+$(Q)$(call ebuild_config_cmd, \
#            $(BTRACE_SRCDIR), \
#            defconfig, \
#            $(btrace_make_args) DEFCONFIG:="$(BTRACE_DEFCONFIG_FILE)")
#endef
#
#define btrace_merge_config_recipe
#+$(Q)$(call ebuild_merge_config_cmd, \
#            $(BTRACE_SRCDIR), \
#            $(wildcard $(BTRACE_CONFIG_FILES)), \
#            $(btrace_make_args))
#endef
#
#define btrace_saveconfig_recipe
#+$(Q)$(call ebuild_saveconfig_cmd,$(BTRACE_SRCDIR),$(btrace_make_args))
#endef
#
#define btrace_guiconfig_recipe
#+$(Q)$(call ebuild_guiconfig_cmd,$(BTRACE_SRCDIR),$(btrace_make_args))
#endef
#
#$(call ebuild_gen_config_rules, \
#       $(BTRACE_CONFIG_FILES), \
#       btrace_defconfig_recipe, \
#       btrace_merge_config_recipe, \
#       btrace_saveconfig_recipe, \
#       btrace_guiconfig_recipe)

################################################################################
# Build logic
################################################################################

define btrace_build_recipe
+$(Q)$(call btrace_make_cmd,build)
endef

$(call ebuild_gen_build_rule,btrace_build_recipe)

################################################################################
# Clean logic
################################################################################

define btrace_clean_recipe
+$(Q)$(call btrace_make_cmd,clean)
endef

$(call ebuild_gen_clean_rule,btrace_clean_recipe)

################################################################################
# Install logic
################################################################################

define btrace_install_recipe
+$(Q)$(call btrace_make_cmd,install,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_install_rule,btrace_install_recipe)

################################################################################
# Uninstall logic
################################################################################

define btrace_uninstall_recipe
+$(Q)$(call btrace_make_cmd,uninstall,DESTDIR:=$(stagingdir))
endef

$(call ebuild_gen_uninstall_rule,btrace_uninstall_recipe)

################################################################################
# Bundle logic
################################################################################

define btrace_bundle_recipe
+$(Q)$(call bundle_lib_cmd,$(stagingdir)/lib/libbtrace.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_bundle_rule,btrace_bundle_recipe)

################################################################################
# Drop logic
################################################################################

define btrace_drop_recipe
+$(Q)$(call drop_lib_cmd,$(stagingdir)/lib/libbtrace.so,$(bundle_rootdir)/lib)
endef

$(call ebuild_gen_drop_rule,btrace_drop_recipe)
